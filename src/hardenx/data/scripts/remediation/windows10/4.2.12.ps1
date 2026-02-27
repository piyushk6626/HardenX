param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Disabled', 'Not Installed')]
    [string]$State
)

try {
    switch ($State) {
        'Disabled' {
            $service = Get-Service -Name 'simptcp' -ErrorAction SilentlyContinue
            if (-not $service) {
                # Service does not exist, which satisfies the 'Disabled' state.
                return $true
            }

            if ($service.StartType -eq 'Disabled' -and $service.Status -eq 'Stopped') {
                # Service is already in the desired state.
                return $true
            }

            if ($service.Status -ne 'Stopped') {
                Stop-Service -Name 'simptcp' -Force -ErrorAction Stop
            }

            if ($service.StartType -ne 'Disabled') {
                Set-Service -Name 'simptcp' -StartupType 'Disabled' -ErrorAction Stop
            }

            return $true
        }
        'Not Installed' {
            $feature = Get-WindowsFeature -Name 'Simple-TCPIP' -ErrorAction SilentlyContinue
            if (-not $feature -or -not $feature.Installed) {
                # Feature is not present or already uninstalled.
                return $true
            }

            $uninstallResult = Uninstall-WindowsFeature -Name 'Simple-TCPIP' -Remove -ErrorAction Stop
            
            if ($uninstallResult.Success) {
                return $true
            } 
            else {
                return $false
            }
        }
    }
}
catch {
    return $false
}