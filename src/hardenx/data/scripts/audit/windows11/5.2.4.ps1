$value = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile' -Name 'DisableNotifications' -ErrorAction SilentlyContinue).DisableNotifications
if ($value -eq 1) {
    'No'
} else {
    'Yes'
}