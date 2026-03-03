try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile' -Name 'AllowLocalPolicyMerge' -ErrorAction Stop
    if ($value -eq 0) {
        'No'
    }
    else {
        'Yes'
    }
}
catch {
    'Yes'
}