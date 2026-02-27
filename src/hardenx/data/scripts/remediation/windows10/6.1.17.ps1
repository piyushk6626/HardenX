[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

try {
    if ($State -eq 'Enabled') {
        Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -NoRestart -ErrorAction Stop | Out-Null
    }
    else {
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -NoRestart -ErrorAction Stop | Out-Null
    }
    return $true
}
catch {
    return $false
}