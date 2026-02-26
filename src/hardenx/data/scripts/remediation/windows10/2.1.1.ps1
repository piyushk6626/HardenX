#requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Principals
)

function Set-UserRight {
    param(
        [string]$UserRight,
        [string]$IdentityList
    )

    $tempInf = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
    $tempSdb = Join-Path $env:TEMP "secedit.sdb"
    $logFile = Join-Path $env:TEMP "secedit.log"
    
    try {
        # Export the current security policy to a temporary INF file
        $exportProc = Start-Process secedit -ArgumentList "/export /cfg `"$tempInf`" /quiet" -Wait -PassThru -NoNewWindow
        if ($exportProc.ExitCode -ne 0) {
            throw "Failed to export current security policy. Exit code: $($exportProc.ExitCode)"
        }

        # Format the principals for the INF file
        $formattedPrincipals = ""
        if (-not [string]::IsNullOrEmpty($IdentityList)) {
            $principalArray = $IdentityList.Split(',') | ForEach-Object { "*$($_.Trim())" }
            $formattedPrincipals = $principalArray -join ','
        }

        # Read the INF file content
        $infContent = Get-Content -Path $tempInf

        # Find the line for the specified user right
        $policyLineIndex = -1
        for ($i = 0; $i -lt $infContent.Count; $i++) {
            if ($infContent[$i].TrimStart() -like "$UserRight =*") {
                $policyLineIndex = $i
                break
            }
        }

        $newLine = "$UserRight = $formattedPrincipals"

        if ($policyLineIndex -ge 0) {
            # Replace the existing line
            $infContent[$policyLineIndex] = $newLine
        }
        else {
            # If the line doesn't exist, find [Privilege Rights] and insert it
            $privilegeRightsIndex = -1
            for ($i = 0; $i -lt $infContent.Count; $i++) {
                if ($infContent[$i].Trim() -eq '[Privilege Rights]') {
                    $privilegeRightsIndex = $i
                    break
                }
            }
            
            if ($privilegeRightsIndex -ge 0) {
                 $infContent = $infContent[0..$privilegeRightsIndex] + $newLine + $infContent[($privilegeRightsIndex + 1)..$infContent.Count]
            } else {
                # This is unlikely, but handle it by appending the section and the line
                $infContent += "[Privilege Rights]", $newLine
            }
        }

        # Write the modified content back to the INF file (ANSI encoding)
        $infContent | Out-File -FilePath $tempInf -Encoding oem
        
        # Configure the system with the new settings
        # The /db parameter needs to point to a writeable SDB file
        $configureProc = Start-Process secedit -ArgumentList "/configure /db `"$tempSdb`" /cfg `"$tempInf`" /log `"$logFile`" /quiet" -Wait -PassThru -NoNewWindow
        if ($configureProc.ExitCode -ne 0) {
            $logContent = if(Test-Path $logFile) { Get-Content $logFile } else { "Log file not found." }
            throw "Failed to apply security policy. Exit code: $($configureProc.ExitCode). Log: $logContent"
        }

        # Success
        return $true

    }
    catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
        return $false
    }
    finally {
        # Clean up temporary files
        if (Test-Path $tempInf) { Remove-Item $tempInf -Force -ErrorAction SilentlyContinue }
        if (Test-Path $tempSdb) { Remove-Item $tempSdb -Force -ErrorAction SilentlyContinue }
        if (Test-Path $logFile) { Remove-Item $logFile -Force -ErrorAction SilentlyContinue }
    }
}

# Call the function with the specific policy and provided principals
Set-UserRight -UserRight 'SeTrustedCredManAccessPrivilege' -IdentityList $Principals