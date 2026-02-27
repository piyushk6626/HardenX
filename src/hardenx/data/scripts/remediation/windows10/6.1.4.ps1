param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$AuditLevel
)

$successArg = ""
$failureArg = ""

switch ($AuditLevel) {
    'Success and Failure' {
        $successArg = "/success:enable"
        $failureArg = "/failure:enable"
    }
    'Success' {
        $successArg = "/success:enable"
        $failureArg = "/failure:disable"
    }
    'Failure' {
        $successArg = "/success:disable"
        $failureArg = "/failure:enable"
    }
    'No Auditing' {
        $successArg = "/success:disable"
        $failureArg = "/failure:disable"
    }
}

try {
    $auditpolArgs = @(
        "/set",
        "/subcategory:`"User Account Management`"",
        $successArg,
        $failureArg
    )
    
    Start-Process -FilePath "auditpol.exe" -ArgumentList $auditpolArgs -Wait -NoNewWindow -PassThru -ErrorAction Stop
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}