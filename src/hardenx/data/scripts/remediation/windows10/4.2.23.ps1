param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Automatic','Manual','Disabled')]
    [string]$StartupType
)

try {
    $service = Get-Service -Name 'XboxGipSvc' -ErrorAction Stop
    if ($service.StartupType -eq $StartupType) {
        return $true
    }
    
    Set-Service -Name 'XboxGipSvc' -StartupType $StartupType -ErrorAction Stop
    return $true
}
catch {
    return $false
}