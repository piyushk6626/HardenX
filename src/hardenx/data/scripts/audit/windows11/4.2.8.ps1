$value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI' -Name 'AllowFileDrop' -ErrorAction SilentlyContinue

if ($value -eq 0) {
    '0'
}
else {
    '1'
}