$regValue = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LimitBlankPasswordUse' -ErrorAction SilentlyContinue
if ($null -ne $regValue -and $regValue.LimitBlankPasswordUse -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}