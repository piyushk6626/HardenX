param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$registryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$valueName = 'VsmPersistency'
$valueData = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord -Force -ErrorAction Stop
    
    $true
}
catch {
    $false
}