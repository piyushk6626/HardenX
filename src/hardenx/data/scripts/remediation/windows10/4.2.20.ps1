param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartType
)

try {
    Set-Service -Name 'PushToInstall' -StartupType $StartType -ErrorAction Stop
    return $true
}
catch {
    return $false
}