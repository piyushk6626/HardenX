param(
    [Parameter(Mandatory = $true)]
    [string]$Status
)

$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'

switch ($Status) {
    'Enabled: All drives' {
        try {
            if (-not (Test-Path -Path $registryPath)) {
                New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
            }
            Set-ItemProperty -Path $registryPath -Name 'NoDriveTypeAutoRun' -Value 255 -Type DWord -Force -ErrorAction Stop
            return $true
        }
        catch {
            return $false
        }
    }
    'Disabled' {
        try {
            if (Test-Path -Path $registryPath) {
                if (Get-ItemProperty -Path $registryPath -Name 'NoDriveTypeAutoRun' -ErrorAction SilentlyContinue) {
                    Remove-ItemProperty -Path $registryPath -Name 'NoDriveTypeAutoRun' -Force -ErrorAction Stop
                }
            }
            return $true
        }
        catch {
            return $false
        }
    }
    default {
        return $false
    }
}