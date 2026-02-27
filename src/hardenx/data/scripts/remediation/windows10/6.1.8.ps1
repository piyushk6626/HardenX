param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$AuditState
)

$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    return $false
}

$arguments = @(
    '/set',
    '/subcategory:"Other Logon/Logoff Events"'
)

switch ($AuditState) {
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

try {
    & auditpol.exe $arguments | Out-Null
    return ($LASTEXITCODE -eq 0)
}
catch {
    return $false
}