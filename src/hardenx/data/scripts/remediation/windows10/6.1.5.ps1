[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success', 'Success and Failure', 'No Auditing')]
    [string]$State
)

try {
    switch ($State) {
        'Success' {
            auditpol /set /subcategory:"Plug and Play Events" /success:enable /failure:disable
        }
        'Success and Failure' {
            auditpol /set /subcategory:"Plug and Play Events" /success:enable /failure:enable
        }
        'No Auditing' {
            auditpol /set /subcategory:"Plug and Play Events" /success:disable /failure:disable
        }
    }

    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}