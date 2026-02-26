param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateRange(0, [int]::MaxValue)]
    [int]$Value
)

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
$valueName = "NtlmMinClientSec"

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $Value -Type DWord -ErrorAction Stop
    
    $true
}
catch {
    $false
}