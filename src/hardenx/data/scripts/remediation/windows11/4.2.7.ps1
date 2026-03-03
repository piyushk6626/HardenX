[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartupType
)

try {
    Set-Service -Name 'TermService' -StartupType $StartupType -ErrorAction Stop
    # The command was successful
    return $true
}
catch {
    # An error occurred
    return $false
}