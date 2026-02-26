param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$registryName = "DontDisplayLastUserName"
$value = 0

if ($State -eq 'Enabled') {
    $value = 1
}

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $value -Type DWord -Force -ErrorAction Stop
    return $true
}
catch {
    return $false
}