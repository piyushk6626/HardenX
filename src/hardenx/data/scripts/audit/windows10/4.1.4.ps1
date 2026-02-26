try {
    $value = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableInstallerDetection' -ErrorAction Stop
    if ($value.EnableInstallerDetection -eq 1) {
        'Enabled'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}