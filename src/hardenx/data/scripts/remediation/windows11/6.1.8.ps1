param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('No Auditing', 'Success', 'Failure', 'Success and Failure')]
    [string]$AuditLevel
)

$auditArgs = switch ($AuditLevel) {
    'No Auditing'         { '/success:disable /failure:disable' }
    'Success'             { '/success:enable /failure:disable' }
    'Failure'             { '/success:disable /failure:enable' }
    'Success and Failure' { '/success:enable /failure:enable' }
}

$command = "auditpol.exe /set /subcategory:`"Other Logon/Logoff Events`" $auditArgs"

try {
    Invoke-Expression $command | Out-Null
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}