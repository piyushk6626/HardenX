[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Success', 'Failure', 'Success and Failure', 'No Auditing')]
    [string]$State
)

try {
    $auditPolArgs = switch ($State) {
        'Success'             { @('/set', '/subcategory:"Process Creation"', '/success:enable', '/failure:disable') }
        'Failure'             { @('/set', '/subcategory:"Process Creation"', '/success:disable', '/failure:enable') }
        'Success and Failure' { @('/set', '/subcategory:"Process Creation"', '/success:enable', '/failure:enable') }
        'No Auditing'         { @('/set', '/subcategory:"Process Creation"', '/success:disable', '/failure:disable') }
    }

    & auditpol.exe $auditPolArgs *>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}