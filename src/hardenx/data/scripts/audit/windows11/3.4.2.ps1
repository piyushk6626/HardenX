try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'NoLMHash' -ErrorAction Stop
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