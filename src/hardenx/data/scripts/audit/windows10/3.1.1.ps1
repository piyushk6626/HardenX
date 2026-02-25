try {
    (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'NoConnectedUser' -ErrorAction Stop).NoConnectedUser
}
catch {
    0
}