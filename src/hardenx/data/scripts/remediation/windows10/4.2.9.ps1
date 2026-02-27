param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$DesiredState
)

try {
    Set-Service -Name 'RpcLocator' -StartupType $DesiredState -ErrorAction Stop
    $true
}
catch {
    $false
}