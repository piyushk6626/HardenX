try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'everyoneincludesanonymous' -ErrorAction Stop
    if ($value -eq 1) {
        'Enabled'
    }
    else {
        'Disabled'
    }
}
catch {
    'Disabled'
}