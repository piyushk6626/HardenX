param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Enabled', 'Disabled', IgnoreCase = $true)]
    [string]$State
)

$registryPath = "HKLM:\System\CurrentControlSet\Control\Lsa"
$registryName = "RestrictAnonymousSAM"
$registryValue = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type DWord -Force -ErrorAction Stop
    return $true
}
catch {
    return $false
}