try {
    (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'InactivityTimeoutSecs' -ErrorAction Stop).InactivityTimeoutSecs
}
catch {
    0
}