[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Disabled', 'Not Installed')]
    [string]$State
)

try {
    switch ($State) {
        'Disabled' {
            $service = Get-Service -Name 'W3SVC' -ErrorAction SilentlyContinue
            if ($null -ne $service) {
                if ($service.StartType -ne 'Disabled') {
                    Set-Service -Name 'W3SVC' -StartupType Disabled -ErrorAction Stop
                }
                if ($service.Status -eq 'Running') {
                    Stop-Service -Name 'W3SVC' -Force -ErrorAction Stop
                }
            }
        }
        'Not Installed' {
            # This assumes a Windows Server environment where Uninstall-WindowsFeature is available.
            $feature = Get-WindowsFeature -Name 'Web-Server' -ErrorAction SilentlyContinue
            if ($null -eq $feature) {
                 # If the Get-WindowsFeature command fails, it could be a client OS.
                 # Attempt to use the client-side equivalent.
                 Disable-WindowsOptionalFeature -Online -FeatureName 'IIS-WebServerRole' -NoRestart -ErrorAction Stop
            }
            elseif ($feature.Installed) {
                 $uninstallResult = Uninstall-WindowsFeature -Name 'Web-Server' -ErrorAction Stop
                 if (-not $uninstallResult.Success) {
                     throw "Failed to uninstall the 'Web-Server' feature."
                 }
            }
        }
    }
    return $true
}
catch {
    return $false
}