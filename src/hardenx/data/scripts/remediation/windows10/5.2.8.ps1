param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateRange(1, 65535)] # Valid range for LogFileSizeKilobytes
    [int]$LogSizeKB
)

try {
    Set-NetFirewallProfile -Profile Public -LogFileSizeKilobytes $LogSizeKB -ErrorAction Stop
    $true
}
catch {
    # Write-Error $_.Exception.Message # Uncomment for debugging
    $false
}