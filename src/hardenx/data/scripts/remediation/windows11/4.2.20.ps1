param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Disabled', 'Automatic', 'Manual')]
    [string]$StartupType
)

try {
    Get-Service -Name 'PushToInstall' -ErrorAction Stop | Set-Service -StartupType $StartupType -ErrorAction Stop
    return $true
}
catch {
    return $false
}