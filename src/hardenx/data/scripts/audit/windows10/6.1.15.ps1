$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$regValueName = "NoLockScreenCamera"
$regValueData = Get-ItemProperty -Path $regPath -Name $regValueName -ErrorAction SilentlyContinue

if ($null -ne $regValueData -and $regValueData.$regValueName -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}