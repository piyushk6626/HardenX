param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled', 'Automatic (Delayed Start)')]
    [string]$StartupType
)

$serviceName = 'Browser'

try {
    $service = Get-Service -Name $serviceName -ErrorAction Stop

    # Set the startup type. No need to change it if it's already set.
    if ($service.StartupType -ne $StartupType) {
        Set-Service -Name $serviceName -StartupType $StartupType -ErrorAction Stop
    }

    # If the service is running, stop it.
    # We refresh the service object in case its status changed.
    if ((Get-Service -Name $serviceName).Status -eq 'Running') {
        Stop-Service -Name $serviceName -Force -ErrorAction Stop
    }

    # If all operations complete without error, the state is considered successfully configured.
    return $true
}
catch {
    # If any error occurs (e.g., service not found, access denied), return false.
    return $false
}