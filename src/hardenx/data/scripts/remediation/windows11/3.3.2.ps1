param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
$valueName = 'EnableForcedLogoff'
$valueData = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $valueName -Value $valueData -Type DWord -ErrorAction Stop

    return $true
}
catch {
    return $false
}