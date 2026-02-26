param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$valueName = "DisableDomainCreds"

$valueData = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord -Force -ErrorAction Stop
    return $true
}
catch {
    return $false
}