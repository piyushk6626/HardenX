[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateRange(0, 999)]
    [int]$Threshold
)

try {
    # Suppress the "Command completed successfully." message
    net accounts /lockoutthreshold:$Threshold *>&1 | Out-Null
    # $? automatically contains $true if the last command succeeded (exit code 0)
    # and $false otherwise.
    Write-Output $?
}
catch {
    # If a script-terminating error occurs (e.g., bad parameter binding)
    Write-Output $false
}