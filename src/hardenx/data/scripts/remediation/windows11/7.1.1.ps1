param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('0', '1')]
    [string]$State
)

$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$ValueName = 'AuditApplicationGuard'
$ValueData = [int]$State

try {
    if (-not (Test-Path -Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $ValueData -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}