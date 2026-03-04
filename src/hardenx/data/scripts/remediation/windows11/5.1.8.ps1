#Requires -RunAsAdministrator

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Yes', 'No', IgnoreCase = $true)]
    [string]$Action
)

try {
    $logValue = switch ($Action.ToLower()) {
        'yes' { $true }
        'no'  { $false }
    }
    
    Set-NetFirewallProfile -Profile Private -LogAllowed $logValue -ErrorAction Stop
    return $true
}
catch {
    return $false
}