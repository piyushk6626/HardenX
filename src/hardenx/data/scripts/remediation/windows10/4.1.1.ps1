param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('0', '1')]
    [string]$Status
)

try {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $regName = "FilterAdministratorToken"

    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value ([int]$Status) -Type DWord -ErrorAction Stop
    
    $true
}
catch {
    $false
}