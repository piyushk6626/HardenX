[CmdletBinding(PositionalBinding=$true)]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$registryPath = "HKLM:\System\CurrentControlSet\Control\Lsa"
$registryName = "DisableDomainCreds"
$value = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $value -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}