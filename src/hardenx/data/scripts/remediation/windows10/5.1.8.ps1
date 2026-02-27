param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Yes', 'No')]
    [string]$Confirmation
)

try {
    $state = switch ($Confirmation) {
        'Yes' { 'enable' }
        'No'  { 'disable' }
    }

    $arguments = "advfirewall set privateprofile setting successconnections $state"
    Start-Process -FilePath "netsh.exe" -ArgumentList $arguments -Wait -WindowStyle Hidden -PassThru

    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}