try {
    Set-NetFirewallProfile -Profile 'Public' -DefaultOutboundAction $args[0] -ErrorAction Stop
    $true
}
catch {
    $false
}