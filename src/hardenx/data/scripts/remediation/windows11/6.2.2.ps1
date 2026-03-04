param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Setting
)

if ($Setting -eq 'Enabled: Do not execute any autorun commands') {
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    $valueName = 'NoAutorun'
    $desiredValue = 255

    try {
        $currentProperty = Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue
        if ($null -ne $currentProperty -and $currentProperty.$valueName -eq $desiredValue) {
            return $true
        }

        if (-not (Test-Path -Path $regPath)) {
            New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
        }
        
        Set-ItemProperty -Path $regPath -Name $valueName -Value $desiredValue -Type DWord -Force -ErrorAction Stop
        
        $verifyValue = (Get-ItemProperty -Path $regPath -Name $valueName).$valueName
        if ($verifyValue -eq $desiredValue) {
            return $true
        } else {
            return $false
        }
    }
    catch {
        return $false
    }
}

return $false