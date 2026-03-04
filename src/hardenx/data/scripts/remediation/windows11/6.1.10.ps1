param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$AuditLevel
)

try {
    $successArg = '/success:disable'
    $failureArg = '/failure:disable'

    switch ($AuditLevel) {
        'Success and Failure' {
            $successArg = '/success:enable'
            $failureArg = '/failure:enable'
            break
        }
        'Success' {
            $successArg = '/success:enable'
            break
        }
        'Failure' {
            $failureArg = '/failure:enable'
            break
        }
    }

    & auditpol.exe /set /subcategory:"Removable Storage" $successArg $failureArg *>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    }
    else {
        return $false
    }
}
catch {
    return $false
}