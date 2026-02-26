try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI' -Name 'AuditApplicationGuard' -ErrorAction Stop
    if ($value -eq 1) {
        '1'
    }
    else {
        '0'
    }
}
catch {
    '0'
}