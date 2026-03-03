[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

try {
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $valueName = "everyoneincludesanonymous"
    $valueData = if ($State -eq 'Enabled') { 1 } else { 0 }

    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}