#requires -RunAsAdministrator

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$value = if ($State -eq 'Enabled') { 1 } else { 0 }
$tempInf = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName() + '.inf')
$tempSdb = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName() + '.sdb')
$success = $false

$infContent = @"
[Unicode]
Unicode=yes
[System Access]
ClearTextPassword = $value
[Version]
signature="`$CHICAGO`$"
Revision=1
"@

try {
    Set-Content -Path $tempInf -Value $infContent -Encoding Unicode -Force
    
    $arguments = "/configure /db `"$tempSdb`" /cfg `"$tempInf`" /quiet"
    $process = Start-Process -FilePath "secedit.exe" -ArgumentList $arguments -Wait -PassThru -WindowStyle Hidden
    
    if ($process.ExitCode -eq 0) {
        $success = $true
    }
}
catch {
    # Any exception results in failure
    $success = $false
}
finally {
    if (Test-Path $tempInf) {
        Remove-Item -Path $tempInf -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path $tempSdb) {
        Remove-Item -Path $tempSdb -Force -ErrorAction SilentlyContinue
    }
}

return $success