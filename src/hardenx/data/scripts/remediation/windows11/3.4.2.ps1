param (
    [Parameter(Mandatory=$true)]
    [string]$DesiredState
)

if ($DesiredState -ne 'Enabled') {
    return $false
}

try {
    $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
    $regName = 'NoLMHash'
    $regValue = 1
    
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}