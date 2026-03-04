[CmdletBinding()]
param (
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('No Auditing', 'Success', 'Failure', 'Success and Failure')]
    [string]$State
)

try {
    $successArg = ''
    $failureArg = ''

    switch ($State) {
        'No Auditing' {
            $successArg = '/success:disable'
            $failureArg = '/failure:disable'
        }
        'Success' {
            $successArg = '/success:enable'
            $failureArg = '/failure:disable'
        }
        'Failure' {
            $successArg = '/success:disable'
            $failureArg = '/failure:enable'
        }
        'Success and Failure' {
            $successArg = '/success:enable'
            $failureArg = '/failure:enable'
        }
    }

    $auditpolArgs = @(
        '/set',
        '/subcategory:"Account Lockout"',
        $successArg,
        $failureArg
    )

    Start-Process -FilePath 'auditpol.exe' -ArgumentList $auditpolArgs -Wait -NoNewWindow -ErrorAction Stop
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}