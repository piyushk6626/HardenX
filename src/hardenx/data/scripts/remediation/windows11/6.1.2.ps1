param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('No Auditing', 'Success', 'Failure', 'Success and Failure')]
    [string]$State
)

$successSetting = "/success:disable"
$failureSetting = "/failure:disable"

switch ($State) {
    'Success' {
        $successSetting = "/success:enable"
    }
    'Failure' {
        $failureSetting = "/failure:enable"
    }
    'Success and Failure' {
        $successSetting = "/success:enable"
        $failureSetting = "/failure:enable"
    }
}

try {
    # Suppress all output streams from the external command
    auditpol.exe /set /subcategory:"Application Group Management" $successSetting $failureSetting *> $null
    
    # Return $true if the exit code is 0 (success), otherwise $false
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    # If any terminating error occurs (e.g., auditpol.exe not found), return false
    return $false
}