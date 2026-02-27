param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('True', 'False', IgnoreCase = $true)]
    [string]$LogAllowedSetting
)

try {
    Set-NetFirewallProfile -Profile Public -LogAllowed ([System.Convert]::ToBoolean($LogAllowedSetting)) -ErrorAction Stop
    $true
}
catch {
    $false
}