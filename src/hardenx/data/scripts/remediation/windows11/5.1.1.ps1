param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('On', 'Off')]
    [string]$State
)

try {
    $isEnabled = ($State -eq 'On')
    Set-NetFirewallProfile -Profile 'Private' -Enabled $isEnabled -ErrorAction Stop
    $true
}
catch {
    $false
}