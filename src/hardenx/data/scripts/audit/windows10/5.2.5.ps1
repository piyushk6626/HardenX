try {
    $value = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile' -Name 'AllowLocalPolicyMerge' -ErrorAction Stop
    if ($value.AllowLocalPolicyMerge -eq 1) {
        'Yes'
    } else {
        'No'
    }
}
catch {
    'No'
}