param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateRange(0, 24)]
    [int]$HistorySize
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Administrator rights are required to modify security policy.
    return $false
}

$tempInf = Join-Path -Path $env:TEMP -ChildPath "temp_secpol_$(Get-Random).inf"
$tempSdb = Join-Path -Path $env:TEMP -ChildPath "temp_secpol_$(Get-Random).sdb"
$success = $false

try {
    # Export the current security policy to a temporary file
    secedit /export /cfg $tempInf /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to export security policy. secedit exit code: $LASTEXITCODE"
    }

    # Read the file, replace the value, and write it back
    (Get-Content -Path $tempInf -Raw) -replace '(?i)(PasswordHistorySize\s*=\s*)\d+', ('$1' + $HistorySize) | Set-Content -Path $tempInf -Force

    # Import the modified policy
    secedit /configure /db $tempSdb /cfg $tempInf /areas SECURITYPOLICY /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to configure security policy. secedit exit code: $LASTEXITCODE"
    }

    $success = $true
}
catch {
    # Any failure in the process will land here
    $success = $false
}
finally {
    # Clean up temporary files
    if (Test-Path -Path $tempInf) {
        Remove-Item -Path $tempInf -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path $tempSdb) {
        Remove-Item -Path $tempSdb -Force -ErrorAction SilentlyContinue
    }
}

return $success