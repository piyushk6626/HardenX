param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartType
)

$serviceName = 'W3SVC'

try {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

    if ($null -ne $service) {
        Set-Service -Name $serviceName -StartupType $StartType -ErrorAction Stop
    }

    # Return true if the service was configured or if it doesn't exist
    return $true
}
catch {
    # Return false if Set-Service failed
    return $false
}