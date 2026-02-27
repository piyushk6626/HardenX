#requires -RunAsAdministrator

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$valueName = "EnableInstallerDetection"
$valueData = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord -Force -ErrorAction Stop

    $currentValue = (Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction Stop).$valueName
    
    if ($currentValue -eq $valueData) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}