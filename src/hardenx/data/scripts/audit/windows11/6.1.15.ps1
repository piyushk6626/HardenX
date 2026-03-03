$registryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
$registryValueName = 'NoLockScreenCamera'
$value = Get-ItemProperty -Path $registryPath -Name $registryValueName -ErrorAction SilentlyContinue

if ($null -ne $value -and $value.$registryValueName -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}