try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'dontdisplaylastusername' -ErrorAction Stop
    if ($value -eq 1) {
        'Enabled'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}