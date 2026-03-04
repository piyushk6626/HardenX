param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$State
)

try {
    $arguments = @('/set', '/subcategory:"File Share"')

    switch ($State) {
        'Success and Failure' {
            $arguments += '/success:enable', '/failure:enable'
        }
        'Success' {
            $arguments += '/success:enable', '/failure:disable'
        }
        'Failure' {
            $arguments += '/success:disable', '/failure:enable'
        }
        'No Auditing' {
            $arguments += '/success:disable', '/failure:disable'
        }
    }

    & auditpol.exe $arguments | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}