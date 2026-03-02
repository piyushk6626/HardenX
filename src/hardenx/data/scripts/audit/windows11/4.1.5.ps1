$value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -ErrorAction SilentlyContinue
if ($value -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}