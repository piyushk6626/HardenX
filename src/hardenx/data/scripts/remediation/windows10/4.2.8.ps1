param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$registryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$registryName = 'AppHVSI_SaveFilesToHost'
$registryValue = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    # The -Force parameter creates the registry key path if it does not exist.
    New-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -PropertyType DWord -Force -ErrorAction Stop | Out-Null
    return $true
}
catch {
    return $false
}