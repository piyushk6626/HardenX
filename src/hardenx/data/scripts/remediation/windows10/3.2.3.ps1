param(
    [Parameter(Mandatory = $true)]
    [int]$Threshold
)

$registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$valueName = 'MachineAccountLockoutThreshold'

try {
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $Threshold -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}