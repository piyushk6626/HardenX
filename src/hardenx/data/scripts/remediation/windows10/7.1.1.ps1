[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('0', '1')]
    [string]$Status
)

$registryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$registryName = 'AuditApplicationGuard'
$registryValue = [int]$Status

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWord -Force -ErrorAction Stop

    return $true
}
catch {
    return $false
}