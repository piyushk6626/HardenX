param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Action
)

$notifySetting = $null
switch -exact ($Action.ToLower()) {
    'yes' { $notifySetting = $true; break }
    'no'  { $notifySetting = $false; break }
    default {
        return $false
    }
}

try {
    Set-NetFirewallProfile -Profile Private -NotifyOnListen $notifySetting -ErrorAction Stop
    return $true
}
catch {
    return $false
}