param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartType
)

try {
    $service = Get-Service -Name WMSvc -ErrorAction SilentlyContinue
    if ($null -ne $service) {
        Set-Service -Name WMSvc -StartupType $StartType
    }
    $true
}
catch {
    $false
}