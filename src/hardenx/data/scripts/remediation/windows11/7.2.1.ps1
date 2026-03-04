param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI"
$valueName = "VsmDisableCameraMicrophone"

if ($State -eq 'Disabled') {
    $registryValue = 1
}
else {
    $registryValue = 0
}

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }
    
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $registryValue -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}