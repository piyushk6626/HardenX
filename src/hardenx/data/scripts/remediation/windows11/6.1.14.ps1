[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$AuditLevel
)

try {
    $auditFlags = switch ($AuditLevel) {
        'Success and Failure' { '/success:enable /failure:enable' }
        'Success'             { '/success:enable /failure:disable' }
        'Failure'             { '/success:disable /failure:enable' }
        'No Auditing'         { '/success:disable /failure:disable' }
    }

    $arguments = @(
        '/set',
        '/subcategory:"System Integrity"'
    ) + $auditFlags.Split(' ')

    Start-Process -FilePath 'auditpol.exe' -ArgumentList $arguments -Wait -NoNewWindow -PassThru
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}