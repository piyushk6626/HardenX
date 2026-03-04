param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
$ValueName = 'NoAutoplayfornonVolume'
$ValueType = 'DWord'

try {
    if (-not (Test-Path -Path $RegistryPath)) {
        $null = New-Item -Path $RegistryPath -Force -ErrorAction Stop
    }

    if ($State -eq 'Enabled') {
        $ValueData = 1
    }
    else {
        $ValueData = 0
    }

    Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $ValueData -Type $ValueType -ErrorAction Stop

    return $true
}
catch {
    return $false
}