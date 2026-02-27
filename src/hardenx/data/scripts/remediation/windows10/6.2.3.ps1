param (
    [Parameter(Mandatory = $true)]
    [ValidateSet('Enabled: All drives', 'Disabled')]
    [string]$PolicyState
)

$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
$regValueName = 'NoDriveTypeAutoRun'

try {
    if ($PolicyState -eq 'Enabled: All drives') {
        if (-not (Test-Path -Path $regPath)) {
            New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name $regValueName -Value 255 -Type DWord -ErrorAction Stop
    }
    elseif ($PolicyState -eq 'Disabled') {
        if (Test-Path -Path $regPath) {
            if (Get-ItemProperty -Path $regPath -Name $regValueName -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path $regPath -Name $regValueName -Force -ErrorAction Stop
            }
        }
    }
    
    return $true
}
catch {
    return $false
}