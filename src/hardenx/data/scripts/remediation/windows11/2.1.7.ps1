param(
    [Parameter(Mandatory=$true)]
    [string]$AccountNames
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # This script requires administrative privileges.
    return $false
}

$infPath = $null
$sdbPath = $null
$success = $false

try {
    $tempDir = $env:TEMP
    $infFile = [System.IO.Path]::GetRandomFileName() + ".inf"
    $sdbFile = [System.IO.Path]::GetRandomFileName() + ".sdb"
    $infPath = Join-Path -Path $tempDir -ChildPath $infFile
    $sdbPath = Join-Path -Path $tempDir -ChildPath $sdbFile

    # Create the security template content
    $infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeTimeZonePrivilege = $AccountNames
"@

    # Write the template to a temporary file
    Set-Content -Path $infPath -Value $infContent -Encoding Unicode -Force

    # Import the template into a new security database
    # Redirecting stdout and stderr to null to suppress command output
    secedit.exe /import /db "$sdbPath" /cfg "$infPath" /overwrite /quiet *> $null 2> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to import security template using secedit. Exit code: $LASTEXITCODE"
    }

    # Apply the security policy from the database
    secedit.exe /configure /db "$sdbPath" /quiet *> $null 2> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to configure security policy using secedit. Exit code: $LASTEXITCODE"
    }
    
    $success = $true

} catch {
    # Any error in the process will result in failure
    $success = $false
} finally {
    # Clean up temporary files
    if ($infPath -and (Test-Path -Path $infPath -PathType Leaf)) {
        Remove-Item -Path $infPath -Force -ErrorAction SilentlyContinue
    }
    if ($sdbPath -and (Test-Path -Path $sdbPath -PathType Leaf)) {
        Remove-Item -Path $sdbPath -Force -ErrorAction SilentlyContinue
    }
}

return $success