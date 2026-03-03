param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartupType
)

try {
    Set-Service -Name 'WerSvc' -StartupType $StartupType -ErrorAction Stop
    return $true
}
catch {
    return $false
}