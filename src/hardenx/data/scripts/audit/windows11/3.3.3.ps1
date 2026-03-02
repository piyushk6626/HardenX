$path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$name = 'LsaLookupSids'

$value = Get-ItemPropertyValue -Path $path -Name $name -ErrorAction SilentlyContinue

if ($value -eq 0) {
    'Disabled'
}
else {
    'Enabled'
}