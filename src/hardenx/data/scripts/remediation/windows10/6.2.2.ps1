param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Argument
)

if ($Argument -ne 'Enabled: Do not execute any autorun commands') {
    return $false
}

$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
$regValueName = 'NoDriveTypeAutoRun'
$regValueData = 255
$regValueType = 'DWord'

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }
    
    Set-ItemProperty -Path $regPath -Name $regValueName -Value $regValueData -Type $regValueType -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}