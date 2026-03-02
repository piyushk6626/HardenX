if ((Get-NetFirewallProfile -Name Private).Enabled) {
    'On'
}
else {
    'Off'
}