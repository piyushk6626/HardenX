param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$Value
)

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
$regName = 'NtlmMinClientSec'

try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $Value -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}