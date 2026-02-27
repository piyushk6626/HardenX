param(
    [Parameter(Mandatory=$true, Position=0)]
    [bool]$Enabled
)

try {
    Set-NetFirewallProfile -Profile Private -Enabled $Enabled -ErrorAction Stop
    return $true
}
catch {
    return $false
}