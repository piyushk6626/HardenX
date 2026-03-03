[CmdletBinding(PositionalBinding=$true)]
param(
    [Parameter(Position=0, Mandatory=$true, HelpMessage="Enter 0 for Disabled or 1 for Enabled")]
    [ValidateSet('0', '1')]
    [int]$State
)

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$RegValueName = 'AllowFileDrop'

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force -ErrorAction Stop | Out-Null
    }

    Set-ItemProperty -Path $RegPath -Name $RegValueName -Value $State -Type DWord -Force -ErrorAction Stop

    $true
}
catch {
    $false
}