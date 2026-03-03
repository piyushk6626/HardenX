param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$Seconds
)

$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$valueName = 'InactivityTimeoutSecs'

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $valueName -Value $Seconds -Type DWord -ErrorAction Stop

    return $true
}
catch {
    return $false
}