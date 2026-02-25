$regValue = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'EnableForcedLogoff' -ErrorAction SilentlyContinue

if ($null -ne $regValue -and $regValue.EnableForcedLogoff -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}