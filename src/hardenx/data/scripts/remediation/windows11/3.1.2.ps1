[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$Status
)

try {
    $user = Get-LocalUser -Name 'Guest' -ErrorAction Stop

    if ($Status -eq 'Enabled') {
        $user | Enable-LocalUser -ErrorAction Stop
    }
    else {
        $user | Disable-LocalUser -ErrorAction Stop
    }

    return $true
}
catch {
    return $false
}