param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Automatic', 'Manual', 'Disabled', 'AutomaticDelayedStart')]
    [string]$StartType
)

try {
    Set-Service -Name 'RemoteAccess' -StartupType $StartType -ErrorAction Stop
    return $true
}
catch {
    return $false
}