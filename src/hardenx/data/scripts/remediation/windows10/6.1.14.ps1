param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$AuditLevel
)

try {
    $successState = 'disable'
    $failureState = 'disable'

    switch ($AuditLevel) {
        'Success and Failure' {
            $successState = 'enable'
            $failureState = 'enable'
        }
        'Success' {
            $successState = 'enable'
        }
        'Failure' {
            $failureState = 'enable'
        }
        'No Auditing' {
            # States are already set to disable by default
        }
    }

    auditpol.exe /set /subcategory:"System Integrity" /success:$successState /failure:$failureState | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}