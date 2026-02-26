[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [int]$Days
)

try {
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    $propName = 'PasswordExpiryWarning'
    
    Set-ItemProperty -Path $regPath -Name $propName -Value $Days -Type DWord -ErrorAction Stop
    
    $true
}
catch {
    $false
}