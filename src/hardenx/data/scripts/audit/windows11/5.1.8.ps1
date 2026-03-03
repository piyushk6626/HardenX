if ((Get-NetFirewallProfile -Profile Private).LogAllowed -eq 'True') {
    'Yes'
}
else {
    'No'
}