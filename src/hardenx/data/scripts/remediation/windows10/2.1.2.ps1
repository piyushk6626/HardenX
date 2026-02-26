param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Sids
)

$infFile = Join-Path -Path $env:TEMP -ChildPath "UserRights-$(Get-Random).inf"
$sdbFile = Join-Path -Path $env:TEMP -ChildPath "UserRights-$(Get-Random).sdb"
$logFile = Join-Path -Path $env:TEMP -ChildPath "UserRights.log"

$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeNetworkLogonRight = $Sids
"@

try {
    $infContent | Set-Content -Path $infFile -Encoding Unicode -Force
    
    secedit.exe /configure /db $sdbFile /cfg $infFile /log $logFile /quiet
    
    if ($LASTEXITCODE -eq 0) {
        $true
    }
    else {
        $false
    }
}
finally {
    if (Test-Path -Path $infFile) {
        Remove-Item -Path $infFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path $sdbFile) {
        Remove-Item -Path $sdbFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path $logFile) {
        Remove-Item -Path $logFile -Force -ErrorAction SilentlyContinue
    }
}