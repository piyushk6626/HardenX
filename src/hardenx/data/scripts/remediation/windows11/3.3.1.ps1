param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$Value
)

$regPath = "HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters"
$regName = "autodisconnect"

try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $Value -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}