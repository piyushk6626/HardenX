[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$Minutes
)

$registryPath = "HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters"
$valueName = "autodisconnect"

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }
    
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $Minutes -Type DWord -Force -ErrorAction Stop
    
    $true
}
catch {
    $false
}