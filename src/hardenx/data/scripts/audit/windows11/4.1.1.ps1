try {
    $value = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'FilterAdministratorToken' -ErrorAction Stop
    if ($value.FilterAdministratorToken -eq 1) {
        'Enabled'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}