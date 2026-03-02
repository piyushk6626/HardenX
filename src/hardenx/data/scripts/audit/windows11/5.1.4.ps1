if ((Get-NetFirewallProfile -Profile Private).DisableNotifications) {
    'No'
}
else {
    'Yes'
}