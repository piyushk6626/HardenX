param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$DesiredState
)

$serviceName = 'WMPNetworkSvc'

# Use -ErrorAction SilentlyContinue to prevent an error if the service doesn't exist.
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -eq $service) {
    # Service not found, which is a success condition per the requirements.
    return $true
}

try {
    Set-Service -Name $serviceName -StartupType $DesiredState -ErrorAction Stop
    # If the command succeeds, return true.
    return $true
}
catch {
    # If Set-Service fails for any reason (e.g., permissions, invalid state), return false.
    return $false
}