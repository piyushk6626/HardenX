param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartupType
)

try {
    Set-Service -Name 'XboxGipSvc' -StartupType $StartupType -ErrorAction Stop
    $true
}
catch {
    $false
}