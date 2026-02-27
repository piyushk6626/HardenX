param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Block', 'Allow')]
    [string]$Action
)

try {
    Set-NetFirewallProfile -Profile Public -DefaultInboundAction $Action -ErrorAction Stop
    $true
}
catch {
    $false
}