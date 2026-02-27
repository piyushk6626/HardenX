param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('0', '1')]
    [string]$State
)

$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$regValueName = 'AllowCameraMicrophoneRedirection'
$valueData = [int]$State

try {
    if (-not (Test-Path -Path $regPath -PathType Container)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regValueName -Value $valueData -Type DWord -Force -ErrorAction Stop

    return $true
}
catch {
    return $false
}