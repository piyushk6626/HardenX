try {
    $value = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile' -Name 'AllowLocalIPsecPolicy' -ErrorAction Stop
    if ($value.AllowLocalIPsecPolicy -eq 0) {
        'No'
    } else {
        'Yes'
    }
}
catch {
    'Yes'
}