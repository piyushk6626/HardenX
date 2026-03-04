param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('No Auditing', 'Success', 'Failure', 'Success and Failure')]
    [string]$Setting
)

try {
    $auditArgs = switch ($Setting) {
        'No Auditing'         { @('/success:disable', '/failure:disable') }
        'Success'             { @('/success:enable', '/failure:disable') }
        'Failure'             { @('/success:disable', '/failure:enable') }
        'Success and Failure' { @('/success:enable', '/failure:enable') }
    }

    $commandArgs = @('/set', '/subcategory:"PNP Activity"') + $auditArgs
    
    & auditpol.exe $commandArgs

    return ($LASTEXITCODE -eq 0)
}
catch {
    return $false
}