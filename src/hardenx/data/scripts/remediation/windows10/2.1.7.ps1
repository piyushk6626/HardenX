param(
    [Parameter(Mandatory=$true)]
    [string]$Principals
)

$infFile = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".inf")
$logFile = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".log")
$success = $false

$infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeTimeZonePrivilege = $Principals
"@

try {
    $infContent | Set-Content -Path $infFile -Encoding Unicode -Force
    
    secedit.exe /configure /db secedit.sdb /cfg "$infFile" /log "$logFile" /quiet
    
    if ($LASTEXITCODE -eq 0) {
        $success = $true
    }
}
catch {
    $success = $false
}
finally {
    if (Test-Path -Path $infFile) {
        Remove-Item -Path $infFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path $logFile) {
        Remove-Item -Path $logFile -Force -ErrorAction SilentlyContinue
    }
}

$success