[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Success', 'Failure', 'Success and Failure', 'No Auditing')]
    [string]$State
)

$successState = $false
$failureState = $false

switch ($State) {
    'Success' {
        $successState = $true
        $failureState = $false
    }
    'Failure' {
        $successState = $false
        $failureState = $true
    }
    'Success and Failure' {
        $successState = $true
        $failureState = $true
    }
    'No Auditing' {
        $successState = $false
        $failureState = $false
    }
}

$successArg = "/success:$($successState.ToString().ToLower())"
$failureArg = "/failure:$($failureState.ToString().ToLower())"

try {
    & auditpol.exe /set /subcategory:"Security Group Management" $successArg $failureArg *>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}