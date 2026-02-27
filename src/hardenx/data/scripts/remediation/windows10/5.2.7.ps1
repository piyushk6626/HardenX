param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$LogFilePath
)

try {
    Set-NetFirewallProfile -Profile Public -LogFileName $LogFilePath -ErrorAction Stop
    $true
}
catch {
    $false
}