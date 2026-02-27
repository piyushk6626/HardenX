param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartupType
)

try {
    Set-Service -Name 'SessionEnv' -StartupType $StartupType -ErrorAction Stop
    $true
}
catch {
    $false
}