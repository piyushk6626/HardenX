param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$AuditingLevel
)

$successSetting = $null
$failureSetting = $null

switch ($AuditingLevel) {
    'Success and Failure' {
        $successSetting = '/success:enable'
        $failureSetting = '/failure:enable'
    }
    'Success' {
        $successSetting = '/success:enable'
        $failureSetting = '/failure:disable'
    }
    'Failure' {
        $successSetting = '/success:disable'
        $failureSetting = '/failure:enable'
    }
    'No Auditing' {
        $successSetting = '/success:disable'
        $failureSetting = '/failure:disable'
    }
}

try {
    & auditpol.exe /set /subcategory:"User Account Management" $successSetting $failureSetting
    return $?
}
catch {
    return $false
}