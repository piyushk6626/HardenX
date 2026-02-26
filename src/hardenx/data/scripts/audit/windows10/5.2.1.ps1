if ((Get-NetFirewallProfile -Name 'Public').Enabled) {
    'Enabled'
} else {
    'Disabled'
}