[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Automatic', 'AutomaticDelayedStart', 'Manual', 'Disabled')]
    [string]$StartupType
)

$serviceName = 'WMPNetworkSvc'

# Attempt to get the service.
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

# If the service does not exist, the operation is considered successful.
if (-not $service) {
    return $true
}

# If the service exists, attempt to configure it.
try {
    Set-Service -InputObject $service -StartupType $StartupType -ErrorAction Stop
    # If the previous command succeeded, return true.
    return $true
}
catch {
    # If any error occurred during Set-Service (e.g., permissions), return false.
    return $false
}