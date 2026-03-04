[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('No Auditing', 'Success', 'Failure', 'Success and Failure')]
    [string]$AuditState
)

try {
    $successSwitch = ''
    $failureSwitch = ''

    switch ($AuditState) {
        'No Auditing' {
            $successSwitch = '/success:disable'
            $failureSwitch = '/failure:disable'
        }
        'Success' {
            $successSwitch = '/success:enable'
            $failureSwitch = '/failure:disable'
        }
        'Failure' {
            $successSwitch = '/success:disable'
            $failureSwitch = '/failure:enable'
        }
        'Success and Failure' {
            $successSwitch = '/success:enable'
            $failureSwitch = '/failure:enable'
        }
    }

    auditpol.exe /set /subcategory:"Other Policy Change Events" $successSwitch $failureSwitch
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}