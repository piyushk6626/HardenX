[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Block', 'Allow', 'NotConfigured')]
    [string]$Action
)

try {
    Set-NetFirewallProfile -Profile Private -DefaultInboundAction $Action -ErrorAction Stop
    return $true
}
catch {
    return $false
}