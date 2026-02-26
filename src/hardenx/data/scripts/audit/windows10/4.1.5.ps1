$regValue = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -ErrorAction SilentlyContinue

if (($null -eq $regValue) -or ($regValue.EnableLUA -eq 1)) {
    'Enabled'
}
else {
    'Disabled'
}