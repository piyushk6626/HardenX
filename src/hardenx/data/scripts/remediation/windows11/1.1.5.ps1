param (
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$Setting
)

$value = if ($Setting -eq 'Enabled') { 1 } else { 0 }
$infFile = Join-Path -Path $env:TEMP -ChildPath "temp-secpolicy.inf"
$sdbFile = Join-Path -Path $env:TEMP -ChildPath "temp-secpolicy.sdb"

try {
    # Export the current security policy to a temporary file
    secedit.exe /export /cfg $infFile /quiet
    if ($LASTEXITCODE -ne 0) {
        # Failed to export, likely permissions issue.
        return $false
    }

    # Read the file and replace the PasswordComplexity line
    $config = (Get-Content -Path $infFile) | ForEach-Object {
        if ($_ -match '^\s*PasswordComplexity\s*=') {
            "PasswordComplexity = $value"
        }
        else {
            $_
        }
    }
    
    # Write the modified configuration back to the file
    Set-Content -Path $infFile -Value $config -Force

    # Import the modified policy
    secedit.exe /configure /db $sdbFile /cfg $infFile /quiet
    if ($LASTEXITCODE -ne 0) {
        # Failed to import the new setting.
        return $false
    }

    # If we reached here, it was successful.
    return $true
}
catch {
    # Catch any unexpected script errors
    return $false
}
finally {
    # Clean up the temporary files
    if (Test-Path -Path $infFile) {
        Remove-Item -Path $infFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path $sdbFile) {
        Remove-Item -Path $sdbFile -Force -ErrorAction SilentlyContinue
    }
}