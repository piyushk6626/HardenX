param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$NewName
)

try {
    $AdminUser = Get-LocalUser | Where-Object { $_.SID.Value -like '*-500' }
    
    if ($null -eq $AdminUser) {
        throw "Administrator account with SID ending in -500 not found."
    }
    
    $AdminUser | Rename-LocalUser -NewName $NewName -ErrorAction Stop
    
    $true
}
catch {
    $false
}