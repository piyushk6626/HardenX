```powershell
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Disabled', 'Not Installed')]
    [string]$DesiredState
)

try {
    if ($DesiredState -eq 'Disabled') {
        $service = Get-Service -Name 'simptcp' -ErrorAction SilentlyContinue
        if ($null -eq $service) {
            # Service doesn't exist to be changed.
            return $false
        }
        
        Set-Service -Name 'simptcp' -StartupType Disabled -ErrorAction Stop
        Stop-Service -Name 'simptcp' -Force -ErrorAction Stop
        
        return $true
    }
    elseif ($DesiredState -eq 'Not Installed') {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName 'SimpleTCPServices' -ErrorAction SilentlyContinue
        
        # If the feature isn't present or isn't enabled, it cannot be changed.
        if ($null -eq $feature -or $feature.State -ne 'Enabled') {
            return $false
        }

        Disable-WindowsOptionalFeature -Online -FeatureName 'SimpleTCPServices' -NoRestart -ErrorAction Stop
        
        return $true
    }
}
catch {
    return $false
}

# Fallback in case of unexpected logic path
return $false
```