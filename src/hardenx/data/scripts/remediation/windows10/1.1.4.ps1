param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateRange(0, 14)]
    [int]$Length
)

$tempInf = $null
try {
    $tempInf = [System.IO.Path]::GetTempFileName()
    $dbPath = Join-Path -Path $env:windir -ChildPath "security\database\secedit.sdb"

    secedit /export /cfg $tempInf /quiet
    if ($LASTEXITCODE -ne 0) { throw "Failed to export security policy." }

    $configContent = Get-Content -Path $tempInf -Raw
    $newConfigContent = $configContent -replace '(?m)^MinimumPasswordLength\s*=\s*\d+', "MinimumPasswordLength = $Length"
    Set-Content -Path $tempInf -Value $newConfigContent -Force

    secedit /configure /db $dbPath /cfg $tempInf /quiet
    if ($LASTEXITCODE -ne 0) { throw "Failed to configure security policy." }

    $true
}
catch {
    $false
}
finally {
    if ($null -ne $tempInf -and (Test-Path -Path $tempInf)) {
        Remove-Item -Path $tempInf -Force -ErrorAction SilentlyContinue
    }
}