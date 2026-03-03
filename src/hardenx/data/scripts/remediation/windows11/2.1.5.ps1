[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

$infFile = $null
$sdbFile = $null

try {
    $infFile = [System.IO.Path]::GetTempFileName()
    $sdbFile = [System.IO.Path]::GetTempFileName() + ".sdb"

    # Secedit requires principals to be prefixed with a '*'
    $seceditPrincipals = ($Identity.Split(',') | ForEach-Object { "*$($_.Trim())" }) -join ','

    # Create the security template content
    $infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeBackupPrivilege = $($seceditPrincipals)
"@

    # Write the template to the temp file with Unicode encoding
    Set-Content -Path $infFile -Value $infContent -Encoding Unicode -Force

    # Import the template into a temporary security database
    $importResult = Start-Process -FilePath "secedit" -ArgumentList "/import /db `"$sdbFile`" /cfg `"$infFile`" /quiet" -Wait -PassThru
    if ($importResult.ExitCode -ne 0) {
        throw "Failed to import security template. Secedit exit code: $($importResult.ExitCode)"
    }

    # Apply the security policy from the database
    $configureResult = Start-Process -FilePath "secedit" -ArgumentList "/configure /db `"$sdbFile`" /quiet" -Wait -PassThru
    if ($configureResult.ExitCode -ne 0) {
        throw "Failed to configure security policy. Secedit exit code: $($configureResult.ExitCode)"
    }

    return $true
}
catch {
    return $false
}
finally {
    # Clean up temporary files
    if ($infFile -and (Test-Path $infFile)) {
        Remove-Item $infFile -Force -ErrorAction SilentlyContinue
    }
    if ($sdbFile -and (Test-Path $sdbFile)) {
        Remove-Item $sdbFile -Force -ErrorAction SilentlyContinue
    }
}