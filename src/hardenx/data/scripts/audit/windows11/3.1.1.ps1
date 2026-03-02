$value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'NoConnectedUser' -ErrorAction SilentlyContinue

if ($null -eq $value) {
    0
}
else {
    $value
}