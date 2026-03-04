param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$State
)

try {
    $successState = 'disable'
    $failureState = 'disable'

    switch ($State) {
        'Success and Failure' {
            $successState = 'enable'
            $failureState = 'enable'
        }
        'Success' {
            $successState = 'enable'
        }
        'Failure' {
            $failureState = 'enable'
        }
        # 'No Auditing' uses the default values
    }

    # Ensure the script is run with elevated privileges
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        # Not elevated, return failure
        return $false
    }
    
    $auditPolArgs = "/set /subcategory:`"Sensitive Privilege Use`" /success:$successState /failure:$failureState"
    
    Start-Process -FilePath "auditpol.exe" -ArgumentList $auditPolArgs -Wait -NoNewWindow -PassThru
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}