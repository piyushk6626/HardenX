[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('On', 'Off')]
    [string]$State
)

try {
    $enabledState = ($State -eq 'On')
    Set-NetFirewallProfile -Profile Public -Enabled $enabledState -ErrorAction Stop
    return $true
}
catch {
    return $false
}