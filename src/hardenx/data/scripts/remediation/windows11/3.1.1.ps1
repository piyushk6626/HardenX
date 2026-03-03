param (
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('0', '1', '3')]
    [string]$DesiredState
)

$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$regValueName = "NoConnectedUser"

try {
    Set-ItemProperty -Path $regPath -Name $regValueName -Value ([int]$DesiredState) -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}