param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^\d+$')]
    [string]$DecimalValue
)

$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
$valueName = 'SupportedEncryptionTypes'

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $registryPath -Name $valueName -Value ([int]$DecimalValue) -Type DWord -Force -ErrorAction Stop
    
    $true
}
catch {
    $false
}