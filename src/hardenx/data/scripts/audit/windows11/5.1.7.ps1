if ((Get-NetFirewallProfile -Name Private).LogDroppedPackets) {
    "Yes"
}
else {
    "No"
}