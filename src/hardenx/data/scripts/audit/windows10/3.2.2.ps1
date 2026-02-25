$value = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'DontDisplayLastUserName' -ErrorAction SilentlyContinue).DontDisplayLastUserName

if ($value -eq 1) {
    'Enabled'
}
else {
    'Disabled'
}