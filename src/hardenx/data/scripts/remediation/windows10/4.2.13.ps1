param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('Disabled', 'Not Installed')]
    [string]$DesiredState
)

try {
    if ($DesiredState -eq 'Disabled') {
        $service = Get-Service -Name 'SNMP' -ErrorAction SilentlyContinue
        if ($null -ne $service) {
            if ($service.StartType -ne 'Disabled') {
                Set-Service -Name 'SNMP' -StartupType Disabled -ErrorAction Stop
            }
        }
    }
    elseif ($DesiredState -eq 'Not Installed') {
        # The capability name for the SNMP Service feature
        $capabilityName = 'SNMP.Client~~~~0.0.1.0'
        $capability = Get-WindowsCapability -Online -Name $capabilityName -ErrorAction SilentlyContinue
        
        if ($null -ne $capability -and $capability.State -eq 'Installed') {
            Remove-WindowsCapability -Online -Name $capabilityName -ErrorAction Stop | Out-Null
        }
    }
    return $true
}
catch {
    return $false
}