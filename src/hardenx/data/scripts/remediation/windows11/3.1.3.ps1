#requires -RunAsAdministrator

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$regName = 'LimitBlankPasswordUse'
$value = $null

switch ($State) {
    'Enabled' { $value = 1 }
    'Disabled' { $value = 0 }
}

try {
    # Ensure the registry path exists before attempting to set the property
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value $value -Type DWord -Force -ErrorAction Stop
    return $true
}
catch {
    return $false
}