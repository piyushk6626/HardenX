param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$Status
)

try {
    $isEnabled = ($Status -eq 'Enabled')
    Set-LocalUser -Name 'Guest' -Enabled $isEnabled -ErrorAction Stop
    return $true
}
catch {
    return $false
}