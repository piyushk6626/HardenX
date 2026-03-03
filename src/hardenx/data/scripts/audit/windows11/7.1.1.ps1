try {
    $value = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI' -Name 'AuditApplicationGuard' -ErrorAction Stop
    if ($value.AuditApplicationGuard -eq 1) {
        '1'
    }
    else {
        '0'
    }
}
catch {
    '0'
}