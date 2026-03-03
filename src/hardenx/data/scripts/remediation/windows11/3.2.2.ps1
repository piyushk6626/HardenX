#requires -RunAsAdministrator

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled', IgnoreCase = $true)]
    [string]$State
)

$regPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
$valueName = 'dontdisplaylastusername'
$valueData = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name $valueName -Value $valueData -Type DWord -Force -ErrorAction Stop
    return $true
}
catch {
    return $false
}