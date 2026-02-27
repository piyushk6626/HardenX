param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('No Auditing', 'Success', 'Failure', 'Success and Failure')]
    [string]$AuditState
)

try {
    $successArg = '/success:disable'
    $failureArg = '/failure:disable'

    switch ($AuditState) {
        'Success' {
            $successArg = '/success:enable'
        }
        'Failure' {
            $failureArg = '/failure:enable'
        }
        'Success and Failure' {
            $successArg = '/success:enable'
            $failureArg = '/failure:enable'
        }
    }
    
    $auditpolArgs = @(
        '/set',
        '/subcategory:"Audit Policy Change"',
        $successArg,
        $failureArg
    )

    # Suppress output from the external command
    auditpol.exe @auditpolArgs *>$null

    if ($LASTEXITCODE -ne 0) {
        throw "auditpol.exe failed with exit code $LASTEXITCODE."
    }

    return $true
}
catch {
    return $false
}