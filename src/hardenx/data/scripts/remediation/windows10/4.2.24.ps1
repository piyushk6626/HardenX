param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled', 'AutomaticDelayedStart')]
    [string]$StartupType
)

try {
    Set-Service -Name 'XblAuthManager' -StartupType $StartupType -ErrorAction Stop
    $true
}
catch {
    $false
}