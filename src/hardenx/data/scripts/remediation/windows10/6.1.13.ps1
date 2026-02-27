param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$AuditSetting
)

$arguments = switch ($AuditSetting) {
    'Success and Failure' { '/set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable' }
    'Success'             { '/set /subcategory:"Sensitive Privilege Use" /success:enable /failure:disable' }
    'Failure'             { '/set /subcategory:"Sensitive Privilege Use" /success:disable /failure:enable' }
    'No Auditing'         { '/set /subcategory:"Sensitive Privilege Use" /success:disable /failure:disable' }
}

try {
    & auditpol.exe $arguments *> $null
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}