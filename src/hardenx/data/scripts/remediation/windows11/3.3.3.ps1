[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$Status
)

$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$ValueName = 'LsaLookupSids'
$IntegerValue = 0

if ($Status -eq 'Enabled') {
    $IntegerValue = 1
}

try {
    Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $IntegerValue -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}