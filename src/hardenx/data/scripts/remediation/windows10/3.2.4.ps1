[CmdletBinding(PositionalBinding=$true)]
param (
    [Parameter(Mandatory=$true, Position=0, HelpMessage="The inactivity timeout in seconds.")]
    [int]$TimeoutSeconds
)

$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$registryName = "InactivityTimeoutSecs"

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $TimeoutSeconds -Type DWord -ErrorAction Stop
    return $true
}
catch {
    return $false
}