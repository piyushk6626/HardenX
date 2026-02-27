param(
    [Parameter(Mandatory = $true)]
    [string]$State
)

try {
    $success = $null
    $failure = $null

    switch ($State) {
        'No Auditing' {
            $success = 'disable'
            $failure = 'disable'
        }
        'Success' {
            $success = 'enable'
            $failure = 'disable'
        }
        'Failure' {
            $success = 'disable'
            $failure = 'enable'
        }
        'Success and Failure' {
            $success = 'enable'
            $failure = 'enable'
        }
        default {
            # Invalid state provided
            return $false
        }
    }

    auditpol.exe /set /subcategory:"Removable Storage" /success:$success /failure:$failure

    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}