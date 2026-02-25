try {
    $value = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LimitBlankPasswordUse' -ErrorAction Stop
    if ($value.LimitBlankPasswordUse -eq 1) {
        'Enabled'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}