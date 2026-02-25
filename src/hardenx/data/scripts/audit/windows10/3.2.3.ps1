$value = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'MachineAccountLockoutThreshold' -ErrorAction SilentlyContinue
if ($null -eq $value) {
    '0'
}
else {
    $value
}