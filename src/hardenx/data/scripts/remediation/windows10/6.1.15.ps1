param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$regName = "NoLockScreenCamera"
$regValue = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}