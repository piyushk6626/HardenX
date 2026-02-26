param(
    [Parameter(Position=0, Mandatory=$true)]
    [int]$EncryptionValue
)

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'
$RegValueName = 'SupportedEncryptionTypes'

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force -ErrorAction Stop | Out-Null
    }

    $CurrentSetting = Get-ItemProperty -Path $RegPath -Name $RegValueName -ErrorAction SilentlyContinue

    if ($null -ne $CurrentSetting -and $CurrentSetting.$RegValueName -eq $EncryptionValue) {
        Write-Host $true
        exit
    }

    Set-ItemProperty -Path $RegPath -Name $RegValueName -Value $EncryptionValue -Type DWord -Force -ErrorAction Stop

    $NewSetting = (Get-ItemProperty -Path $RegPath -Name $RegValueName).$RegValueName
    Write-Host ($NewSetting -eq $EncryptionValue)
}
catch {
    Write-Host $false
}