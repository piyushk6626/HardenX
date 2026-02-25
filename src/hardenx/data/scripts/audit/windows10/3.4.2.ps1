try {
    $value = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'NoLMHash' -ErrorAction Stop
    if ($value.NoLMHash -eq 1) {
        'Enabled'
    } else {
        'Disabled'
    }
}
catch {
    'Disabled'
}