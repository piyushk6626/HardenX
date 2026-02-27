param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$DesiredState
)

$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$RegistryValueName = 'AllowDataPersistence'
$Value = if ($DesiredState -eq 'Enabled') { 1 } else { 0 }

try {
    if (-not (Test-Path -Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $RegistryPath -Name $RegistryValueName -Value $Value -Type DWord -ErrorAction Stop

    return $true
}
catch {
    return $false
}