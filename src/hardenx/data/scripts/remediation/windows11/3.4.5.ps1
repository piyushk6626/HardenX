[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateRange([int]0, [int]::MaxValue)]
    [int]$Value
)

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
$valueName = "NtlmMinServerSec"

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }
    
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $Value -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}