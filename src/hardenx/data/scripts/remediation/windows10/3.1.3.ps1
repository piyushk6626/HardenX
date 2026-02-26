param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Enabled', 'Disabled', IgnoreCase = $true)]
    [string]$State
)

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$registryName = "LimitBlankPasswordUse"
$registryType = "DWord"

$registryValue = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -Type $registryType -ErrorAction Stop
    $true
}
catch {
    $false
}