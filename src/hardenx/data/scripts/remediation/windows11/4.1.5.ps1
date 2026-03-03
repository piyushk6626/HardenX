param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$State
)

if ($args[0] -ne 'Enabled' -and $args[0] -ne 'Disabled') {
    $false
    exit
}

$regValue = if ($args[0] -eq 'Enabled') { 1 } else { 0 }
$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$valueName = 'EnableLUA'

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name $valueName -Value $regValue -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}