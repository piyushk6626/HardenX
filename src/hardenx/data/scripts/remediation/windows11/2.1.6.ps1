```powershell
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$AccountNames
)

$privilegeName = "SeSystemtimePrivilege"
$infPath = Join-Path $env:TEMP "$(New-Guid).inf"
$logPath = Join-Path $env:TEMP "$(New-Guid).log"
$tempDb = Join-Path $env:TEMP "$(New-Guid).sdb"

$Success = try {
    # Requires administrative privileges to run secedit and translate some SIDs
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run with administrative privileges."
    }

    # 1. Convert account names to SIDs
    $sids = @()
    $accountArray = $AccountNames.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }

    foreach ($account in $accountArray) {
        try {
            $ntAccount = New-Object System.Security.Principal.NTAccount($account)
            $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
            # secedit.exe requires an asterisk prefix for SIDs in the INF file
            $sids += "*$($sid)"
        }
        catch {
            # Fail if any account name cannot be resolved
            throw "Failed to resolve account name '$account' to a SID."
        }
    }
    $sidsString = $sids -join ','

    # 2. Export current security policy
    secedit /export /cfg $infPath /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to export security policy using secedit.exe."
    }

    # 3. Modify the exported policy file
    $configFile = Get-Content -Path $infPath -Raw
    $privilegeLine = "$privilegeName = $sidsString"

    if ($configFile -match "(?m)^$privilegeName\s*=") {
        $configFile = $configFile -replace "(?m)^$privilegeName\s*=.*", $privilegeLine
    } else {
        $configFile = $configFile -replace '(\[Privilege Rights\])', "`$1`r`n$privilegeLine"
    }

    # Secedit requires Unicode encoding for the INF file
    $configFile | Set-Content -Path $infPath -Encoding Unicode -Force

    # 4. Import the modified policy
    secedit /configure /db $tempDb /cfg $infPath /areas USER_RIGHTS /log $logPath /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to configure security policy using secedit.exe."
    }

    $true
}
catch {
    $false
}
finally {
    # 5. Clean up temporary files
    if (Test-Path $infPath) { Remove-Item $infPath -Force -ErrorAction SilentlyContinue }
    if (Test-Path $logPath) { Remove-Item $logPath -Force -ErrorAction SilentlyContinue }
    if (Test-Path -LiteralPath $tempDb) { Remove-Item -LiteralPath $tempDb -Force -ErrorAction SilentlyContinue }
}

$Success
```