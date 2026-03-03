```powershell
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$AccountNames
)

$success = $false
$tempInf = $null
$tempSdb = $null
$logFile = $null

try {
    # This script requires elevated privileges.
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run with Administrator privileges."
    }

    $sids = $AccountNames.Split(',') | ForEach-Object {
        $accountName = $_.Trim()
        if (-not ([string]::IsNullOrWhiteSpace($accountName))) {
            try {
                $ntAccount = New-Object System.Security.Principal.NTAccount($accountName)
                # Secedit requires SIDs to be prefixed with an asterisk
                "*" + $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
            }
            catch {
                throw "Failed to resolve account name '$accountName' to a SID."
            }
        }
    }

    if (-not $sids) {
        # This handles an empty input string or one with only commas/whitespace.
        # Setting the right to nothing effectively removes all accounts.
        $sidString = ""
    }
    else {
        $sidString = $sids -join ','
    }

    $tempInf = Join-Path $env:TEMP "$(New-Guid).inf"
    $tempSdb = Join-Path $env:TEMP "$(New-Guid).sdb"
    $logFile = Join-Path $env:TEMP "$(New-Guid).log"

    # Export current user rights settings to a temporary file
    secedit.exe /export /cfg $tempInf /areas USER_RIGHTS /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Secedit.exe failed to export the security policy. Exit code: $LASTEXITCODE"
    }

    # Create the INF file content for the import
    $infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[User Rights Assignment]
SeNetworkLogonRight = $sidString
"@

    # Write the new configuration to the temporary INF file
    $infContent | Set-Content -Path $tempInf -Encoding Unicode

    # Import the modified settings from the temporary file
    secedit.exe /configure /db $tempSdb /cfg $tempInf /areas USER_RIGHTS /log $logFile /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Secedit.exe failed to configure the security policy. Exit code: $LASTEXITCODE"
    }

    $success = $true
}
catch {
    # Any exception will result in failure. The 'success' variable remains false.
    # Errors could be written to the error stream for diagnostics if needed, e.g., Write-Error $_
}
finally {
    # Clean up all temporary files
    foreach ($file in @($tempInf, $tempSdb, $logFile)) {
        if ($file -and (Test-Path $file)) {
            Remove-Item $file -Force -ErrorAction SilentlyContinue
        }
    }
    # Output the final status
    $success
}
```