$value = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -ErrorAction SilentlyContinue
if ($null -ne $value -and $value.PromptOnSecureDesktop -eq 0) {
    'Disabled'
}
else {
    'Enabled'
}