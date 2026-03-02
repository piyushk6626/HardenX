$regValue = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Lsa' -Name 'RestrictAnonymousSAM' -ErrorAction SilentlyContinue
if ($null -ne $regValue -and $regValue.RestrictAnonymousSAM -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}