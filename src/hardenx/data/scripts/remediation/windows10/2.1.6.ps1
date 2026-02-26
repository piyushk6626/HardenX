#requires -RunAsAdministrator

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$AccountNames
)

$privilegeName = "SeSystemtimePrivilege"
$infFile = $null
$sdbFile = $null
$logFile = $null

try {
    $sidStrings = @()
    $accounts = $AccountNames.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }

    if ($accounts.Count -eq 0) {
        $sidList = ""
    }
    else {
        foreach ($account in $accounts) {
            try {
                $ntAccount = New-Object System.Security.Principal.NTAccount($account)
                $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier])
                $sidStrings += "*$($sid.Value)"
            }
            catch {
                throw "Failed to resolve account name '$account' to a SID."
            }
        }
        $sidList = $sidStrings -join ','
    }

    $infFile = [System.IO.Path]::GetTempFileName()
    $sdbFile = [System.IO.Path]::GetTempFileName()
    $logFile = [System.IO.Path]::GetTempFileName()

    $infContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
$privilegeName = $sidList
"@

    Set-Content -Path $infFile -Value $infContent -Encoding Unicode -Force

    $process = Start-Process -FilePath "secedit.exe" -ArgumentList "/configure /db `"$sdbFile`" /cfg `"$infFile`" /overwrite /quiet /log `"$logFile`"" -Wait -PassThru -WindowStyle Hidden
    
    if ($process.ExitCode -ne 0) {
        throw "secedit.exe failed with exit code $($process.ExitCode)."
    }

    $true
}
catch {
    $false
}
finally {
    if ($infFile -and (Test-Path $infFile)) { Remove-Item $infFile -Force -ErrorAction SilentlyContinue }
    if ($sdbFile -and (Test-Path $sdbFile)) { Remove-Item $sdbFile -Force -ErrorAction SilentlyContinue }
    if ($logFile -and (Test-Path $logFile)) { Remove-Item $logFile -Force -ErrorAction SilentlyContinue }
}