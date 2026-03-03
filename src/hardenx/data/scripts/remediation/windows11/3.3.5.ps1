[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [string]$State
)

try {
    $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
    $regName = 'RestrictAnonymous'
    $regValue = $null

    switch (($State -as [string]).ToLowerInvariant()) {
        'enabled' {
            $regValue = 1
        }
        'disabled' {
            $regValue = 0
        }
        default {
            # Invalid or missing argument, return false
            return $false
        }
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}