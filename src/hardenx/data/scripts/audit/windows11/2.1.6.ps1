$tempFile = $null
try {
    $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    secedit.exe /export /cfg $tempFile /quiet | Out-Null
    
    $settingLine = Get-Content -Path $tempFile | Select-String -Pattern '^\s*SeSystemtimePrivilege\s*=' -CaseSensitive

    if ($settingLine) {
        $principalsRaw = ($settingLine.Line -split '=', 2)[1].Trim()
        if (-not [string]::IsNullOrEmpty($principalsRaw)) {
            $principalList = $principalsRaw.Split(',') | ForEach-Object { $_.Trim() }
            
            $resolvedNames = foreach ($principal in $principalList) {
                $principalName = $principal.TrimStart('*')
                try {
                    $sid = New-Object System.Security.Principal.SecurityIdentifier($principalName)
                    # Translate to NTAccount and strip domain/computer name if present
                    $account = $sid.Translate([System.Security.Principal.NTAccount]).Value
                    if ($account.Contains('\')) {
                        ($account -split '\\', 2)[1]
                    } else {
                        $account
                    }
                }
                catch {
                    # If it's not a SID, return the original name
                    $principalName
                }
            }
            $resolvedNames -join ','
        }
    }
}
finally {
    if ($tempFile -and (Test-Path -Path $tempFile)) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}