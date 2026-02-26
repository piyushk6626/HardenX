try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\Software\Policies\Microsoft\Windows\Explorer' -Name 'NoAutoplayfornonVolume' -ErrorAction Stop
    if ($value -eq 1) {
        'Enabled'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}