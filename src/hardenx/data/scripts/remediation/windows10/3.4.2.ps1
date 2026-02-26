[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled', IgnoreCase = $true)]
    [string]$State
)

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$regName = 'NoLMHash'
$regValue = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}