try {
    $value = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoDriveTypeAutoRun' -ErrorAction Stop
    if ($value.NoDriveTypeAutoRun -eq 255) {
        'Enabled: All drives'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}