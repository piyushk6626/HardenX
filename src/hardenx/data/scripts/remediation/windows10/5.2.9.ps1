[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Yes', 'No', IgnoreCase=$true)]
    [string]$Action
)

try {
    $logSetting = if ($Action -eq 'Yes') { $true } else { $false }
    Set-NetFirewallProfile -Profile Public -LogDroppedPackets $logSetting -ErrorAction Stop
    $true
}
catch {
    $false
}