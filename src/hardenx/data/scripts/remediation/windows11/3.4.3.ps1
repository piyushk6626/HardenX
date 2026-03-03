param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('None', 'Negotiate signing', 'Require signing')]
    [string]$SigningLevel
)

$valueMap = @{
    'None'                = 1
    'Negotiate signing'   = 2
    'Require signing'     = 3
}

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\ldap'
$regValueName = 'LdapClientIntegrity'
$numericValue = $valueMap[$SigningLevel]

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regValueName -Value $numericValue -Type DWord -Force -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}