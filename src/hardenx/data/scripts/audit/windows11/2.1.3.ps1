$tempFile = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString() + ".inf")
try {
    secedit.exe /export /cfg $tempFile /quiet
    $privilegeLine = Get-Content $tempFile | Select-String -Pattern "SeIncreaseQuotaPrivilege" -SimpleMatch
    if ($null -ne $privilegeLine) {
        $sids = ($privilegeLine.Line -split '=')[1].Trim() -split ',' | ForEach-Object { $_.Trim().TrimStart('*') }
        $accountNames = foreach ($sidString in $sids) {
            if (-not [string]::IsNullOrWhiteSpace($sidString)) {
                try {
                    $sidObject = New-Object System.Security.Principal.SecurityIdentifier($sidString)
                    $account = $sidObject.Translate([System.Security.Principal.NTAccount]).Value
                    ($account -split '\\')[-1]
                }
                catch {
                    # Ignore SIDs that cannot be translated
                }
            }
        }
        $accountNames -join ','
    }
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}