param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success', 'Failure', 'Success and Failure', 'No Auditing')]
    [string]$AuditSetting
)

try {
    $successState = 'disable'
    $failureState = 'disable'

    switch ($AuditSetting) {
        'Success' {
            $successState = 'enable'
        }
        'Failure' {
            $failureState = 'enable'
        }
        'Success and Failure' {
            $successState = 'enable'
            $failureState = 'enable'
        }
        # 'No Auditing' case is covered by the initial state
    }

    auditpol.exe /set /subcategory:"Process Creation" /success:$successState /failure:$failureState | Out-Null

    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}