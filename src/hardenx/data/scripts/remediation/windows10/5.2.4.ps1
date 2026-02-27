param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Yes', 'No')]
    [string]$State
)

$boolValue = ($State -eq 'Yes')

try {
    Set-NetFirewallProfile -Name 'Public' -NotifyOnListen $boolValue -ErrorAction Stop
    $true
}
catch {
    $false
}