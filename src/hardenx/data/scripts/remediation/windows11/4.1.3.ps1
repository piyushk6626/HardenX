param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet(0, 1, 3)]
    [int]$DesiredState
)

$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$regValueName = 'ConsentPromptBehaviorUser'

try {
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regValueName -Value $DesiredState -Type DWord -ErrorAction Stop

    $currentValue = Get-ItemPropertyValue -Path $regPath -Name $regValueName -ErrorAction SilentlyContinue
    
    if ($null -ne $currentValue -and $currentValue -eq $DesiredState) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}