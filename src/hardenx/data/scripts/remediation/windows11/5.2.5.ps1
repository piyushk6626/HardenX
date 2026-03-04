[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Yes', 'No')]
    [string]$AllowMerge
)

$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile'
$regValueName = 'AllowLocalPolicyMerge'

try {
    $valueToSet = if ($AllowMerge -eq 'Yes') { 1 } else { 0 }

    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regValueName -Value $valueToSet -Type DWord -Force -ErrorAction Stop

    return $true
}
catch {
    return $false
}