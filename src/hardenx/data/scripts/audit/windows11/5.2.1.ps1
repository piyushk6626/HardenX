if ((Get-NetFirewallProfile -Name Public).Enabled) {
    'On'
}
else {
    'Off'
}