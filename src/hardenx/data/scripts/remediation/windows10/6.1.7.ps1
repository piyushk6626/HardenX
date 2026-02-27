param(
    [Parameter(Mandatory = $true)]
    [string]$AuditSetting
)

try {
    $successState = ''
    $failureState = ''

    switch ($AuditSetting) {
        'No Auditing' {
            $successState = 'disable'
            $failureState = 'disable'
        }
        'Success' {
            $successState = 'enable'
            $failureState = 'disable'
        }
        'Failure' {
            $successState = 'disable'
            $failureState = 'enable'
        }
        'Success and Failure' {
            $successState = 'enable'
            $failureState = 'enable'
        }
        default {
            # Invalid input
            return $false
        }
    }

    # Execute auditpol.exe with the determined settings
    auditpol.exe /set /subcategory:"Account Lockout" /success:$successState /failure:$failureState
    
    # Check the exit code of the last native application
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    # Catch any script-terminating errors during execution
    return $false
}