$registryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
$valueName = 'NoDriveTypeAutoRun'

try {
    $regValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction Stop
    if ($regValue.NoDriveTypeAutoRun -eq 255) {
        'Enabled: Do not execute any autorun commands'
    } else {
        'Disabled or Not Configured'
    }
}
catch {
    'Disabled or Not Configured'
}