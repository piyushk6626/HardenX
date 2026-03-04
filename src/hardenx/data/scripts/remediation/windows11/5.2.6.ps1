param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Yes', 'No', IgnoreCase=$true)]
    [string]$Decision
)

try {
    $regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile'
    $regName = 'AllowLocalIPsecPolicy'
    
    if ($Decision -eq 'Yes') {
        $regValue = 1
    }
    else {
        $regValue = 0
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}