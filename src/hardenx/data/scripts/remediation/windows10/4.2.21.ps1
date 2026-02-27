param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Automatic', 'AutomaticDelayedStart', 'Manual', 'Disabled')]
    [string]$StartupType
)

try {
    Set-Service -Name 'WinRM' -StartupType $StartupType -ErrorAction Stop
    return $true
}
catch {
    return $false
}