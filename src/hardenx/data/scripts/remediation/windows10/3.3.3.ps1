param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled', IgnoreCase = $true)]
    [string]$State
)

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$regName = 'TurnOffAnonymousBlock'
$regValue = 0

if ($State -eq 'Disabled') {
    $regValue = 1
}

try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord -Force -ErrorAction Stop
    return $true
}
catch {
    return $false
}