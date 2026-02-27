param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$State
)

try {
    $auditArgs = switch ($State) {
        'Success and Failure' { '/success:enable /failure:enable' }
        'Success'             { '/success:enable /failure:disable' }
        'Failure'             { '/success:disable /failure:enable' }
        'No Auditing'         { '/success:disable /failure:disable' }
    }

    $arguments = @(
        '/set',
        '/subcategory:"File Share"'
    ) + $auditArgs.Split(' ')

    & auditpol.exe $arguments 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        return $true
    }
    else {
        return $false
    }
}
catch {
    return $false
}