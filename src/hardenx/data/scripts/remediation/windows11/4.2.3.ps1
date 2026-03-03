param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$State
)

try {
    $service = Get-Service -Name 'Browser' -ErrorAction SilentlyContinue
    if ($null -ne $service) {
        Set-Service -InputObject $service -StartupType $State -ErrorAction Stop
    }
    return $true
}
catch {
    return $false
}