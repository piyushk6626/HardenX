#requires -RunAsAdministrator

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateRange(0, 99999)]
    [int]$Minutes
)

$secpolInf = Join-Path -Path $env:TEMP -ChildPath "secpol.inf"
$secpolLog = Join-Path -Path $env:TEMP -ChildPath "secpol.log"
$sdbFile = Join-Path -Path $env:windir -ChildPath "security\database\secedit.sdb"

try {
    # Export current security policy to a temporary file
    secedit.exe /export /cfg "$secpolInf" /quiet
    if ($LASTEXITCODE -ne 0) {
        return $false
    }

    # Read, modify, and write the policy file
    $config = Get-Content -Path $secpolInf
    $settingFound = $false
    for ($i = 0; $i -lt $config.Count; $i++) {
        if ($config[$i].TrimStart() -like 'LockoutDuration =*') {
            $config[$i] = "LockoutDuration = $Minutes"
            $settingFound = $true
            break
        }
    }

    if (-not $settingFound) {
        # This case is unlikely but handles malformed exports
        return $false
    }

    $config | Set-Content -Path $secpolInf -Force

    # Import the modified policy
    secedit.exe /configure /db "$sdbFile" /cfg "$secpolInf" /log "$secpolLog" /quiet
    
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    return $false
}
finally {
    # Clean up temporary files
    if (Test-Path -Path $secpolInf) {
        Remove-Item -Path $secpolInf -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path $secpolLog) {
        Remove-Item -Path $secpolLog -Force -ErrorAction SilentlyContinue
    }
}