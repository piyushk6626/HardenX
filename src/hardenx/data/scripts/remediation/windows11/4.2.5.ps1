param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartupType
)

try {
    $service = Get-Service -Name 'SharedAccess' -ErrorAction Stop

    if ($service.Status -eq 'Running') {
        Stop-Service -InputObject $service -Force -ErrorAction Stop
    }

    Set-Service -InputObject $service -StartupType $StartupType -ErrorAction Stop
    
    $true
}
catch {
    $false
}