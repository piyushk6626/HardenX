if ((Get-NetFirewallProfile -Name Public).AllowLocalIPsecPolicyMerge) {
    Write-Output 'Yes'
} else {
    Write-Output 'No'
}