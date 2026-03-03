```powershell
param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$State
)

# This script requires administrative privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run with administrative privileges."
    # The function must return a boolean value, not just terminate.
    return $false
}

$tempInfPath = $null
$tempLogPath = $null
$success = $false

try {
    # Generate unique temporary file paths
    $tempInfPath = [System.IO.Path]::GetTempFileName()
    $tempLogPath = [System.IO.Path]::GetTempFileName()

    # Step 1: Export the current security configuration to a temporary INF file
    $exportArgs = "/export /cfg `"$tempInfPath`" /log `"$tempLogPath`" /quiet"
    $exportProcess = Start-Process -FilePath "secedit.exe" -ArgumentList $exportArgs -Wait -PassThru -NoNewWindow
    if ($exportProcess.ExitCode -ne 0) {
        throw "Failed to export current security policy. Secedit exit code: $($exportProcess.ExitCode)"
    }

    # Step 2: Modify the INF file content
    $privilegeName = "SeTrustedCredManAccessPrivilege"
    $valueToSet = if ($State -eq 'No One' -or [string]::IsNullOrEmpty($State)) { "" } else { $State }
    $newPolicyLine = "$privilegeName = $valueToSet"

    $infContent = Get-Content -Path $tempInfPath -Raw
    $pattern = "(?im)^$($privilegeName)\s*=.*"

    if ($infContent -match $pattern) {
        $infContent = $infContent -replace $pattern, $newPolicyLine
    }
    else {
        $privilegeSectionHeader = "[Privilege Rights]"
        if ($infContent.Contains($privilegeSectionHeader)) {
             $infContent = $infContent -replace [regex]::Escape($privilegeSectionHeader), "$privilegeSectionHeader`r`n$newPolicyLine"
        } else {
            $infContent += "`r`n$privilegeSectionHeader`r`n$newPolicyLine"
        }
    }

    Set-Content -Path $tempInfPath -Value $infContent -Force

    # Step 3: Configure the system with the modified security template
    $sdbPath = Join-Path -Path $env:windir -ChildPath "security\database\secedit.sdb"
    $configureArgs = "/configure /db `"$sdbPath`" /cfg `"$tempInfPath`" /log `"$tempLogPath`" /quiet"
    $configureProcess = Start-Process -FilePath "secedit.exe" -ArgumentList $configureArgs -Wait -PassThru -NoNewWindow
    if ($configureProcess.ExitCode -ne 0) {
        throw "Failed to apply modified security policy. Secedit exit code: $($configureProcess.ExitCode)"
    }
    
    $success = $true
}
catch {
    Write-Error $_.Exception.Message
    $success = $false
}
finally {
    # Step 4: Clean up temporary files
    if ($tempInfPath -and (Test-Path -Path $tempInfPath)) {
        Remove-Item -Path $tempInfPath -Force -ErrorAction SilentlyContinue
    }
    if ($tempLogPath -and (Test-Path -Path $tempLogPath)) {
        Remove-Item -Path $tempLogPath -Force -ErrorAction SilentlyContinue
    }
}

return $success
```