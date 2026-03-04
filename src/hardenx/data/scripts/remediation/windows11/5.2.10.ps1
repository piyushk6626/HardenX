param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Yes', 'No')]
    [string]$LogAllowed
)

try {
    $logValue = if ($LogAllowed -eq 'Yes') { $true } else { $false }
    Set-NetFirewallProfile -Profile Public -LogAllowed $logValue -ErrorAction Stop
    return $true
}
catch {
    return $false
}