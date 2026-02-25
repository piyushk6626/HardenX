try {
    Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LDAPClientIntegrity' -ErrorAction Stop
}
catch {
    '1'
}