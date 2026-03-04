#requires -RunAsAdministrator

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Yes', 'No', IgnoreCase = $true)]
    [string]$SetNotification
)

try {
    $regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile'
    $regName = 'DisableNotifications'
    
    $dwordValue = if ($SetNotification -eq 'No') { 1 } else { 0 }

    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value $dwordValue -Type DWord -Force -ErrorAction Stop

    return $true
}
catch {
    return $false
}