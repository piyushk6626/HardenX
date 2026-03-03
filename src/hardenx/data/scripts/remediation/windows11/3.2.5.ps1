param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Title
)

$registryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
$registryName = "LegalNoticeCaption"

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    Set-ItemProperty -Path $registryPath -Name $registryName -Value $Title -ErrorAction Stop
    return $true
}
catch {
    return $false
}