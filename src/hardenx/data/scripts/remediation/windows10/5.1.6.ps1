param(
    [Parameter(Position=0, Mandatory=$true, HelpMessage="Specifies the maximum log file size in kilobytes. The value must be between 1 and 32767.")]
    [ValidateRange(1, 32767)]
    [int]$SizeKB
)

try {
    Set-NetFirewallProfile -Profile Private -LogMaxSizeKilobytes $SizeKB -ErrorAction Stop
    $true
}
catch {
    $false
}