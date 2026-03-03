param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$StartupType
)

try {
    Set-Service -Name 'XblAuthManager' -StartupType $StartupType -ErrorAction Stop
    $true
}
catch {
    $false
}