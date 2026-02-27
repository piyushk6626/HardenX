[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$regPath = 'HKLM:\Software\Policies\Microsoft\AppHVSI'
$regValueName = 'AllowFileDownload'
$valueData = 0

if ($State -eq 'Enabled') {
    $valueData = 1
}

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regValueName -Value $valueData -Type DWord -Force -ErrorAction Stop

    return $true
}
catch {
    Write-Error -Message "Failed to set registry value. Error: $($_.Exception.Message)"
    return $false
}