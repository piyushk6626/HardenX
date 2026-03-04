param(
    [Parameter(Position=0, Mandatory=$true)]
    [int]$LogSizeKB
)

try {
    Set-NetFirewallProfile -Profile Private -LogMaxSizeKilobytes $LogSizeKB -ErrorAction Stop
    $true
}
catch {
    $false
}