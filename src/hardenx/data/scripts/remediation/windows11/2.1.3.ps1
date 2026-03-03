```powershell
param (
    [Parameter(Mandatory=$true)]
    [string]$Principals
)

$success = $false
$tempPath = [System.IO.Path]::GetTempPath()
$infFile = Join-Path -Path $tempPath -ChildPath "policy_update_$($(Get-Random).ToString()).inf"
$sdbFile = Join-Path -Path $tempPath -ChildPath "policy_update_$($(Get-Random).ToString()).sdb"

try {
    # 1. Elevate to Admin if not already
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    if (-not $windowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run with administrative privileges."
    }

    # 2. Resolve principal names to SIDs
    $principalNames = $Principals.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrEmpty($_) }
    if ($principalNames.Count -eq 0) {
        throw "No valid principal names were provided."
    }

    $sids = foreach ($name in $principalNames) {
        try {
            $ntAccount = New-Object System.Security.Principal.NTAccount($name)
            $sidObject = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier])
            "*" + $sidObject.Value
        }
        catch {
            throw "Failed to resolve principal name to a SID: '$name'"
        }
    }
    $sidString = $sids -join ','

    # 3. Export current security policy
    secedit /export /cfg "$infFile" /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "secedit.exe failed to export the current policy. Exit code: $LASTEXITCODE"
    }

    # 4. Modify the exported policy file
    $privilegeName = 'SeIncreaseQuotaPrivilege'
    $newLine = "$privilegeName = $sidString"
    
    $configContent = Get-Content -Path $infFile -Encoding Unicode
    $privilegeRightsSectionIndex = [array]::IndexOf($configContent, '[Privilege Rights]')
    
    if ($privilegeRightsSectionIndex -eq -1) {
        throw "Could not find '[Privilege Rights]' section in the exported policy file."
    }

    $privilegeLineIndex = -1
    for ($i = $privilegeRightsSectionIndex; $i -lt $configContent.Length; $i++) {
        if ($configContent[$i].TrimStart().StartsWith("$privilegeName ", [System.StringComparison]::OrdinalIgnoreCase)) {
            $privilegeLineIndex = $i
            break
        }
    }

    if ($privilegeLineIndex -ne -1) {
        $configContent[$privilegeLineIndex] = $newLine
    }
    else {
        $tempList = [System.Collections.Generic.List[string]]::new($configContent)
        $tempList.Insert($privilegeRightsSectionIndex + 1, $newLine)
        $configContent = $tempList.ToArray()
    }
    
    Set-Content -Path $infFile -Value $configContent -Encoding Unicode -Force

    # 5. Configure the system with the new policy
    secedit /configure /db "$sdbFile" /cfg "$infFile" /overwrite /quiet
    if ($LASTEXITCODE -ne 0) {
        throw "secedit.exe failed to configure the new policy. Exit code: $LASTEXITCODE. Check %windir%\security\logs\scesrv.log for details."
    }

    $success = $true

}
catch {
    # Errors are implicitly handled by leaving $success as $false
}
finally {
    # 6. Cleanup temporary files
    if (Test-Path -Path $infFile) {
        Remove-Item -Path $infFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path $sdbFile) {
        Remove-Item -Path $sdbFile -Force -ErrorAction SilentlyContinue
    }
}

return $success
```