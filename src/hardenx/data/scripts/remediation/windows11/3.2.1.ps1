[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$State
)

if ($State.ToLower() -notin @('enabled', 'disabled')) {
    return $false
}

try {
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $regName = 'DisableCAD'
    $regType = 'DWord'
    $regValue = 0

    if ($State.ToLower() -eq 'enabled') {
        $regValue = 1
    }

    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type $regType -Force -ErrorAction Stop

    return $true
}
catch {
    return $false
}