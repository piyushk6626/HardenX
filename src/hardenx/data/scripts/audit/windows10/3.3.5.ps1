$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$regName = 'RestrictAnonymousSAM'

$value = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue

if ($null -ne $value -and $value.$regName -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}