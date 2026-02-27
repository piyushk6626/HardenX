#Requires -RunAsAdministrator

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Success and Failure', 'Success', 'Failure', 'No Auditing')]
    [string]$DesiredState
)

try {
    $successSetting = 'disable'
    $failureSetting = 'disable'

    switch ($DesiredState) {
        'Success and Failure' {
            $successSetting = 'enable'
            $failureSetting = 'enable'
        }
        'Success' {
            $successSetting = 'enable'
        }
        'Failure' {
            $failureSetting = 'enable'
        }
        # 'No Auditing' uses the default 'disable' settings
    }

    # Execute the command and suppress its text output
    auditpol.exe /set /subcategory:"Credential Validation" /success:$successSetting /failure:$failureSetting | Out-Null

    # Return $true if the command succeeded (exit code 0), otherwise $false
    return ($LASTEXITCODE -eq 0)
}
catch {
    # If any other PowerShell error occurs, return $false
    return $false
}