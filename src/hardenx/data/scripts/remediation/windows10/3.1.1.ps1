param (
    [Parameter(Mandatory = $true, Position = 0)]
    [int]$DesiredState
)

$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$valueName = "NoConnectedUser"

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $registryPath -Name $valueName -Value $DesiredState -Type DWord -ErrorAction Stop

    return $true
}
catch {
    return $false
}