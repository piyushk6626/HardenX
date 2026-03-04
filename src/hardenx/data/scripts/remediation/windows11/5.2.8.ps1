param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateRange(1, 2147483647)]
    [int]
    $SizeInKB
)

try {
    Set-NetFirewallProfile -Profile Public -LogFileSizeKilobytes $SizeInKB -ErrorAction Stop
    $true
}
catch {
    $false
}