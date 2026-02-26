param(
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

$regPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
$regName = 'DisableCAD'
$regType = 'DWord'
$targetValue = if ($State -eq 'Enabled') { 1 } else { 0 }

try {
    # Ensure the registry path exists
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    $currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue

    if ($null -ne $currentValue -and $currentValue.$regName -eq $targetValue) {
        return $true
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value $targetValue -Type $regType -Force
    return $true
}
catch {
    return $false
}