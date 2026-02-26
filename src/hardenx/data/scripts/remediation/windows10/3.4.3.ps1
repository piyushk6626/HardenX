param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet(0, 1, 2)]
    [int]$Value
)

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$regName = "LDAPClientIntegrity"

try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $Value -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}