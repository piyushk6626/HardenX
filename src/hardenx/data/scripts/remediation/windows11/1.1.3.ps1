[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateRange(0, 998)]
    [int]$Days
)

if (-not ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Administrator privileges are required.
    return $false
}

$tempInfFile = Join-Path -Path $env:TEMP -ChildPath "SecPolConfig-$([Guid]::NewGuid()).inf"
$tempSdbFile = Join-Path -Path $env:TEMP -ChildPath "secedit-$([Guid]::NewGuid()).sdb"
$success = $false

try {
    # Export current security policy to a temporary file. The /quiet switch suppresses dialog boxes.
    secedit /export /cfg $tempInfFile /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to export the security policy. secedit exit code: $LASTEXITCODE"
    }

    # Read the exported policy file, modify the MinimumPasswordAge setting, and write it back.
    (Get-Content -Path $tempInfFile) -replace 'MinimumPasswordAge = \d+', "MinimumPasswordAge = $Days" | Set-Content -Path $tempInfFile

    # Import the modified policy using a temporary database to apply the settings.
    secedit /configure /db $tempSdbFile /cfg $tempInfFile /areas SECURITYPOLICY /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to configure the security policy. secedit exit code: $LASTEXITCODE"
    }

    # Force a policy update to ensure changes are applied immediately.
    gpupdate /force /quiet &> $null

    # If all commands succeed, set the success flag to true.
    $success = $true
}
catch {
    # Any exception during the process will result in failure.
    $success = $false
}
finally {
    # Clean up temporary files regardless of success or failure.
    if (Test-Path -Path $tempInfFile) {
        Remove-Item -Path $tempInfFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path $tempSdbFile) {
        Remove-Item -Path $tempSdbFile -Force -ErrorAction SilentlyContinue
    }
}

return $success