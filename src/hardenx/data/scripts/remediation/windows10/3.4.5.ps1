param (
    [Parameter(Mandatory = $true, Position = 0)]
    [int]$DWordValue
)

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
$valueName = 'NtlmMinServerSec'

try {
    Set-ItemProperty -Path $regPath -Name $valueName -Value $DWordValue -Type DWord -ErrorAction Stop -Force
    $true
}
catch {
    $false
}