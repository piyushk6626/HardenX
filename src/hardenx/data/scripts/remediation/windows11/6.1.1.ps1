param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$AuditLevel
)

$successSetting = ''
$failureSetting = ''

switch ($AuditLevel) {
    'Success and Failure' {
        $successSetting = 'enable'
        $failureSetting = 'enable'
    }
    'Success' {
        $successSetting = 'enable'
        $failureSetting = 'disable'
    }
    'Failure' {
        $successSetting = 'disable'
        $failureSetting = 'enable'
    }
    'No Auditing' {
        $successSetting = 'disable'
        $failureSetting = 'disable'
    }
}

try {
    auditpol.exe /set /subcategory:"Credential Validation" /success:$successSetting /failure:$failureSetting *>$null
    
    if ($LASTEXITCODE -eq 0) {
        $true
    } else {
        $false
    }
}
catch {
    $false
}