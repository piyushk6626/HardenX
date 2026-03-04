param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet(2, 3, 4)] # 2=Automatic, 3=Manual, 4=Disabled
    [int]$StartType
)

$registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10'
$valueName = 'Start'

try {
    # Check if the path exists before trying to set the property
    if (-not (Test-Path -Path $registryPath)) {
        throw "Registry key not found: $registryPath"
    }

    Set-ItemProperty -Path $registryPath -Name $valueName -Value $StartType -Type DWord -ErrorAction Stop
    $true
}
catch {
    $false
}