param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$AuditLevel
)

try {
    $ErrorActionPreference = 'Stop'
    $arguments = @('/set', '/subcategory:"Application Group Management"')

    switch ($AuditLevel) {
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

    # Using -Wait to ensure LASTEXITCODE is set reliably in all environments
    $process = Start-Process -FilePath "auditpol.exe" -ArgumentList $arguments -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -ne 0) {
        throw "auditpol.exe failed with exit code $($process.ExitCode)."
    }
    
    return $true
}
catch {
    return $false
}