param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$NewName
)

try {
    $guestSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-32-546')
    Get-LocalUser -SID $guestSid -ErrorAction Stop | Rename-LocalUser -NewName $NewName -ErrorAction Stop
    $true
}
catch {
    $false
}