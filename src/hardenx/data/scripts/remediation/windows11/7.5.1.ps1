param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateRange(0, [int]::MaxValue)]
    [int]$Value
)

$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$KeyName = 'ClipboardRedirection'

try {
    if (-not (Test-Path -Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $RegistryPath -Name $KeyName -Value $Value -Type DWord -Force -ErrorAction Stop

    return $true
}
catch {
    return $false
}