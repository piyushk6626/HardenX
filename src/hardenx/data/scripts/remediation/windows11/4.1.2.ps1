param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$DesiredState
)

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$RegistryValueName = "ConsentPromptBehaviorAdmin"

try {
    if (-not (Test-Path -Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $RegistryPath -Name $RegistryValueName -Value $DesiredState -Type DWord -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}