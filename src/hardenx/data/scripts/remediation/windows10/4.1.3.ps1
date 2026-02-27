param(
    [Parameter(Mandatory=$true)]
    [int]$Value
)

try {
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $regName = 'ConsentPromptBehaviorUser'
    
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value $Value -Type DWord -ErrorAction Stop
    return $true
}
catch {
    return $false
}