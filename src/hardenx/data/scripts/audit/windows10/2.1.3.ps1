$tempFile = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString() + ".inf")
try {
    secedit /export /cfg $tempFile /quiet | Out-Null
    $sidsLine = Get-Content $tempFile | Select-String -Pattern "^\s*SeIncreaseQuotaPrivilege\s*=" -ErrorAction SilentlyContinue
    if ($sidsLine) {
        $sids = ($sidsLine.Line -split '=', 2)[1].Trim()
        $names = $sids.Split(',') | ForEach-Object {
            try {
                $sidObject = New-Object System.Security.Principal.SecurityIdentifier($_)
                $account = $sidObject.Translate([System.Security.Principal.NTAccount])
                $account.Value -replace '.*\\'
            } catch {
                # Ignore SIDs that cannot be resolved
            }
        }
        $names -join ','
    }
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}