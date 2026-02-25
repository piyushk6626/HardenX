$valueData = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'TurnOffAnonymousBlock' -ErrorAction SilentlyContinue

if ($valueData -eq 1) {
    'Disabled'
}
else {
    'Enabled'
}