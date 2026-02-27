param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Automatic', 'Manual', 'Disabled', 'AutomaticDelayedStart')]
    [string]$DesiredState
)

try {
    Set-Service -Name 'XblGameSave' -StartupType $DesiredState -ErrorAction Stop
    $true
}
catch {
    $false
}