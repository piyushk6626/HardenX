try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoDriveTypeAutoRun' -ErrorAction Stop
    if ($value -eq 255) {
        'Enabled: All drives'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}