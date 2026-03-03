try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoAutorun' -ErrorAction Stop
    if ($value -eq 255) {
        'Enabled: Do not execute any autorun commands'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}