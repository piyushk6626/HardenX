param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled', IgnoreCase = $true)]
    [string]$State
)

$registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
$valueName = 'EnableForcedLogoff'
$valueType = 'DWord'

if ($State -eq 'Enabled') {
    $valueData = 1
}
else {
    $valueData = 0
}

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }
    
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type $valueType -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}