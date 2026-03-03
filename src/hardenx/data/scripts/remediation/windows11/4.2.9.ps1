param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$State
)

try {
    Set-Service -Name 'RpcLocator' -StartupType $State -ErrorAction Stop
    return $true
}
catch {
    return $false
}