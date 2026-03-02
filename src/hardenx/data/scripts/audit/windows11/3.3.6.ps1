$value = Get-ItemPropertyValue -Path 'HKLM:\System\CurrentControlSet\Control\Lsa' -Name 'DisableDomainCreds' -ErrorAction SilentlyContinue
if ($value -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}