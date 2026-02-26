param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateRange(0, 24)]
    [int]$HistorySize
)

$tempInfPath = Join-Path -Path $env:TEMP -ChildPath "temp-secpolicy.inf"
$success = $false

try {
    secedit.exe /export /cfg "$tempInfPath" /quiet
    if ($LASTEXITCODE -ne 0) { throw "Failed to export security policy." }

    $policyContent = Get-Content -Path $tempInfPath
    $policyContent = $policyContent -replace 'PasswordHistorySize = \d+', "PasswordHistorySize = $HistorySize"
    $policyContent | Set-Content -Path $tempInfPath

    secedit.exe /configure /db secedit.sdb /cfg "$tempInfPath" /areas SECURITYPOLICY /quiet
    if ($LASTEXITCODE -eq 0) {
        $success = $true
    }
}
catch {
    $success = $false
}
finally {
    if (Test-Path -Path $tempInfPath) {
        Remove-Item -Path $tempInfPath -Force -ErrorAction SilentlyContinue
    }
}

$success