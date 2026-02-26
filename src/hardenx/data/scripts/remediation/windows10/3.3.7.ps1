param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$State
)

$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$regName = 'everyoneincludesanonymous'
$value = $null

switch ($State) {
    'Enabled'  { $value = 1 }
    'Disabled' { $value = 0 }
    default    { return $false }
}

try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $value -Type DWord -Force -ErrorAction Stop
    $true
}
catch {
    $false
}