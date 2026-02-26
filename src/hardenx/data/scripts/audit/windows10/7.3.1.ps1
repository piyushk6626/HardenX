try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI' -Name 'AllowDataPersistence' -ErrorAction Stop
    if ($value -eq 1) {
        'Enabled'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}