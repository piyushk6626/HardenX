param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$Setting
)

try {
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $valueName = "PromptOnSecureDesktop"
    $valueData = if ($Setting -eq 'Enabled') { 1 } else { 0 }

    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord -Force -ErrorAction Stop

    return $true
}
catch {
    return $false
}