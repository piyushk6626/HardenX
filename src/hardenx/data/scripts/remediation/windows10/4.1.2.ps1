param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$Value
)

$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$regName = 'ConsentPromptBehaviorAdmin'

try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $Value -Type DWord -ErrorAction Stop -Force
    return $true
}
catch {
    return $false
}