param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$regValueName = 'RestrictAnonymousSAM'
$value = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    Set-ItemProperty -Path $regPath -Name $regValueName -Value $value -Type DWord -Force -ErrorAction Stop
    return $true
}
catch {
    return $false
}