param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Yes', 'No')]
    [string]$Decision
)

try {
    $logValue = ($Decision -eq 'Yes')
    Set-NetFirewallProfile -Profile Public -LogDroppedPackets $logValue -ErrorAction Stop
    return $true
}
catch {
    return $false
}