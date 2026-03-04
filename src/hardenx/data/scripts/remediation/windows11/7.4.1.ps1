param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$RegistryPath = "HKLM:\Software\Policies\Microsoft\AppHVSI"
$ValueName = "AllowFileDownloads"
$ValueType = "DWord"

if ($State -eq 'Enabled') {
    $ValueData = 1
}
else {
    $ValueData = 0
}

try {
    if (-not (Test-Path -Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $ValueData -Type $ValueType -Force -ErrorAction Stop

    return $true
}
catch {
    return $false
}