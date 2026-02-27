param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$registryPath = 'HKLM:\Software\Policies\Microsoft\Windows\Explorer'
$registryValueName = 'NoAutoplayfornonVolume'
$value = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }
    
    Set-ItemProperty -Path $registryPath -Name $registryValueName -Value $value -Type DWord -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}