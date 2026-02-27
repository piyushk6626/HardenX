param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

try {
    Set-NetFirewallProfile -Profile 'Public' -Enabled $State -ErrorAction Stop
    $true
}
catch {
    $false
}