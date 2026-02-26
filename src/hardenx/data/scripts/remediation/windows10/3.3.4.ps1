param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('0', '1')]
    [string]$State
)

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$regName = "RestrictAnonymousSAM"
$regValue = [int]$State

try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}