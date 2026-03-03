param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartupType
)

try {
    Set-Service -Name 'XboxNetApiSvc' -StartupType $StartupType -ErrorAction Stop
    $true
}
catch {
    $false
}