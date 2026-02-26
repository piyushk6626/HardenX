param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$NewName
)

try {
    $adminUser = Get-LocalUser | Where-Object { $_.SID.Value.EndsWith('-500') }
    if ($null -eq $adminUser) {
        throw "Local administrator account (SID ending in -500) not found."
    }
    $adminUser | Rename-LocalUser -NewName $NewName -ErrorAction Stop
    return $true
}
catch {
    return $false
}