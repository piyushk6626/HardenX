try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI' -Name 'AppHVSI_SaveFilesToHost' -ErrorAction Stop
    if ($value -eq 1) {
        'Enabled'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}