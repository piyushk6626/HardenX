[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Specify the full path for the firewall log file.")]
    [string]$Path
)

try {
    Set-NetFirewallProfile -Profile Private -LogFileName $Path -ErrorAction Stop
    $true
}
catch {
    # You can uncomment the following line for debugging purposes to see the actual error.
    # Write-Error $_.Exception.Message
    $false
}