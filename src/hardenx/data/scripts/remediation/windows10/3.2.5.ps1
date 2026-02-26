param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Caption
)

$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
$valueName = "LegalNoticeCaption"

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name $valueName -Value $Caption -Type String -ErrorAction Stop
    $true
}
catch {
    $false
}