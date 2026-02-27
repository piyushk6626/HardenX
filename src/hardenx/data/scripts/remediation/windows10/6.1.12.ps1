param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Success', 'Failure', 'Success and Failure', 'No Auditing')]
    [string]$AuditState
)

$successArg = ""
$failureArg = ""

switch ($AuditState) {
    'Success' {
        $successArg = "/success:enable"
        $failureArg = "/failure:disable"
    }
    'Failure' {
        $successArg = "/success:disable"
        $failureArg = "/failure:enable"
    }
    'Success and Failure' {
        $successArg = "/success:enable"
        $failureArg = "/failure:enable"
    }
    'No Auditing' {
        $successArg = "/success:disable"
        $failureArg = "/failure:disable"
    }
}

try {
    auditpol.exe /set /subcategory:"Other Policy Change Events" $successArg $failureArg | Out-Null
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}