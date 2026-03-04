param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('Success', 'Failure', 'Success and Failure', 'No Auditing')]
    [string]$AuditState
)

try {
    $successAction = "disable"
    $failureAction = "disable"

    switch ($AuditState) {
        'Success' {
            $successAction = "enable"
        }
        'Failure' {
            $failureAction = "enable"
        }
        'Success and Failure' {
            $successAction = "enable"
            $failureAction = "enable"
        }
        # 'No Auditing' is the default state
    }

    auditpol.exe /set /subcategory:"Policy Change" /success:$successAction /failure:$failureAction
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    # This block catches errors, including invalid parameters from ValidateSet
    return $false
}