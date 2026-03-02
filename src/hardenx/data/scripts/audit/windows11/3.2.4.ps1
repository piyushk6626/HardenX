$value = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'InactivityTimeoutSecs' -ErrorAction SilentlyContinue).InactivityTimeoutSecs
if ($null -eq $value) {
    '0'
} else {
    $value
}