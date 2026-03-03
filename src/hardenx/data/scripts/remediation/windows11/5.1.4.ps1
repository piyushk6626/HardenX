param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Yes', 'No', IgnoreCase=$true)]
    [string]$ShowNotifications
)

try {
    $disableValue = $false
    if ($ShowNotifications -eq 'No') {
        $disableValue = $true
    }

    Set-NetFirewallProfile -Profile Private -DisableNotifications $disableValue -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}