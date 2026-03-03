```powershell
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('Automatic', 'Manual', 'Disabled')]
    [string]$StartupType
)

try {
    Set-Service -Name 'RemoteRegistry' -StartupType $StartupType -ErrorAction Stop
    return $true
}
catch {
    return $false
}
```