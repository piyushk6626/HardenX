$cadValue = Get-ItemPropertyValue -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DisableCAD' -ErrorAction SilentlyContinue

if ($cadValue -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}