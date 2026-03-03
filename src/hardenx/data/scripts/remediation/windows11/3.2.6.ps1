param(
    [Parameter(Mandatory=$true,
               Position=0)]
    [ValidateRange(0, 999)]
    [int]$WarningDays
)

$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$regValueName = "PasswordExpiryWarning"

try {
    Set-ItemProperty -Path $regPath -Name $regValueName -Value $WarningDays -Type DWord -Force -ErrorAction Stop
    return $true
}
catch {
    return $false
}