param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('Allow', 'Block')]
    [string]$Action
)

try {
    Set-NetFirewallProfile -Profile Private -DefaultOutboundAction $Action -ErrorAction Stop
    return $true
}
catch {
    return $false
}