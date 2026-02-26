if ((Get-NetFirewallProfile -Name Public).LogDroppedPackets) {
    'Yes'
}
else {
    'No'
}