[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('No Auditing', 'Success', 'Failure', 'Success and Failure')]
    [string]$State
)

try {
    $successArg = "/success:disable"
    $failureArg = "/failure:disable"

    switch ($State) {
        'Success' { $successArg = "/success:enable" }
        'Failure' { $failureArg = "/failure:enable" }
        'Success and Failure' {
            $successArg = "/success:enable"
            $failureArg = "/failure:enable"
        }
    }

    $arguments = @(
        '/set',
        '/subcategory:"Security Group Management"',
        $successArg,
        $failureArg
    )
    
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