param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$DesiredState
)

$ErrorActionPreference = 'Stop'
$serviceName = 'WMSvc'

try {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

    if ($null -eq $service) {
        # Service does not exist, which is considered a success.
        return $true
    }

    # If the desired state is 'Disabled' and the service is not stopped, stop it.
    if (($DesiredState -eq 'Disabled') -and ($service.Status -ne 'Stopped')) {
        Stop-Service -InputObject $service -Force
    }

    # Set the startup type to the desired state.
    Set-Service -InputObject $service -StartupType $DesiredState

    return $true
}
catch {
    return $false
}