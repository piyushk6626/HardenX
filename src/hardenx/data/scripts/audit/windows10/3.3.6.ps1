try {
    $value = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'DisableDomainCreds' -ErrorAction Stop
    if ($value.DisableDomainCreds -eq 1) {
        'Enabled'
    }
    else {
        'Disabled'
    }
}
catch {
    'Disabled'
}