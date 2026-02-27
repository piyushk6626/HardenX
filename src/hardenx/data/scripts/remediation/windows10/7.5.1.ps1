param(
    [Parameter(Mandatory = $true, Position = 0)]
    [int]$Value
)

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$ValueName = 'ClipboardOptions'

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $RegPath -Name $ValueName -Value $Value -Type DWord -ErrorAction Stop
    
    $true
}
catch {
    $false
}