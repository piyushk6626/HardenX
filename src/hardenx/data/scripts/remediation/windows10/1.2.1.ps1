[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateRange(0, 99999)]
    [int]$Minutes
)

$tempInfPath = $null
$tempSdbPath = $null
$success = $false

try {
    $tempInfPath = [System.IO.Path]::GetTempFileName()
    $tempSdbPath = [System.IO.Path]::GetTempFileName()

    $infContent = @"
[Unicode]
Unicode=yes
[System Access]
LockoutDuration = $Minutes
[Version]
signature="`$CHICAGO`$"
Revision=1
"@

    Set-Content -Path $tempInfPath -Value $infContent -Encoding Unicode -Force

    secedit.exe /configure /db $tempSdbPath /cfg $tempInfPath /quiet
    
    if ($LASTEXITCODE -eq 0) {
        $success = $true
    }
}
catch {
    $success = $false
}
finally {
    if ($tempInfPath -and (Test-Path -Path $tempInfPath)) {
        Remove-Item -Path $tempInfPath -Force -ErrorAction SilentlyContinue
    }
    if ($tempSdbPath -and (Test-Path -Path $tempSdbPath)) {
        Remove-Item -Path $tempSdbPath -Force -ErrorAction SilentlyContinue
    }
}

return $success