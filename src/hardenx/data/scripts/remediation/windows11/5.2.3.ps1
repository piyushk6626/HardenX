[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Allow', 'Block')]
    [string]$Action
)

try {
    Set-NetFirewallProfile -Profile 'Public' -DefaultOutboundAction $Action -ErrorAction Stop
    return $true
}
catch {
    return $false
}