param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$State
)

try {
    $service = Get-Service -Name 'SNMP' -ErrorAction SilentlyContinue

    if ($null -ne $service) {
        Set-Service -Name $service.Name -StartupType $State -ErrorAction Stop
    }

    return $true
}
catch {
    return $false
}