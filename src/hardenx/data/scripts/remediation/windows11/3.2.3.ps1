param (
    [Parameter(Mandatory=$true, Position=0)]
    [int]$Value
)

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\RemoteAccess\Parameters\AccountLockout"
$valueName = "MaxDenials"

try {
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $Value -Type DWord -ErrorAction Stop
    $true
}
catch {
    $false
}