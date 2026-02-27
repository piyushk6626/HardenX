param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Yes', 'No')]
    [string]$EnableLogging
)

try {
    $logValue = ($EnableLogging -eq 'Yes')
    Set-NetFirewallProfile -Profile Private -LogDroppedPackets $logValue -ErrorAction Stop
    return $true
}
catch {
    return $false
}