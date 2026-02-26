param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$NewName
)

try {
    Get-LocalUser -SID 'S-1-5-32-546' | Rename-LocalUser -NewName $NewName -ErrorAction Stop
    $true
}
catch {
    $false
}