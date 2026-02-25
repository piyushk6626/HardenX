$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
$ValueName = 'SupportedEncryptionTypes'

$Value = Get-ItemPropertyValue -Path $RegistryPath -Name $ValueName -ErrorAction SilentlyContinue

if ($null -eq $Value) {
    0
} else {
    $Value
}