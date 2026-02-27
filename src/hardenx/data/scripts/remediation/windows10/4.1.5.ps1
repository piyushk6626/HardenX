param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Enabled', 'Disabled', IgnoreCase=$true)]
    [string]$UacStatus
)

$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regValueName = "EnableLUA"
$value = if ($UacStatus -eq 'Enabled') { 1 } else { 0 }

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regValueName -Value $value -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}