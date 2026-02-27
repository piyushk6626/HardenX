param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$State
)

try {
    switch -Wildcard ($State) {
        'Enabled' {
            Enable-WindowsOptionalFeature -Online -FeatureName 'SMB1Protocol-Client' -NoRestart -ErrorAction Stop
            return $true
        }
        'Disabled' {
            Disable-WindowsOptionalFeature -Online -FeatureName 'SMB1Protocol-Client' -NoRestart -ErrorAction Stop
            return $true
        }
        default {
            return $false
        }
    }
}
catch {
    return $false
}