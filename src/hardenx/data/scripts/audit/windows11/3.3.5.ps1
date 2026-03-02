try {
    $RegValue = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'RestrictAnonymous' -ErrorAction Stop
    if ($RegValue.RestrictAnonymous -eq 1) {
        'Enabled'
    }
    else {
        'Disabled'
    }
}
catch {
    'Disabled'
}