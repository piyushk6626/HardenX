[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('0', '1')]
    [string]$State
)

$tempInfFile = $null

try {
    $tempInfFile = New-TemporaryFile
    $infContent = "[System Access]`nEnableAdminAccountLockout = $State"
    Set-Content -Path $tempInfFile.FullName -Value $infContent

    $secDbPath = Join-Path -Path $env:windir -ChildPath "security\new.sdb"
    
    $process = Start-Process -FilePath "secedit.exe" -ArgumentList "/configure /db `"$secDbPath`" /cfg `"$($tempInfFile.FullName)`" /quiet" -Wait -NoNewWindow -PassThru
    
    if ($process.ExitCode -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}
finally {
    if ($null -ne $tempInfFile -and (Test-Path -Path $tempInfFile.FullName)) {
        Remove-Item -Path $tempInfFile.FullName -Force -ErrorAction SilentlyContinue
    }
}