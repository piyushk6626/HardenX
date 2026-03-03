try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI' -Name 'VsmDisableCameraMicrophone' -ErrorAction Stop
    if ($value -eq 1) {
        'Disabled'
    }
    else {
        'Enabled'
    }
}
catch {
    'Enabled'
}