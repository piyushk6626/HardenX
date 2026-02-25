$tempFile = Join-Path $env:TEMP -ChildPath "policy-$([Guid]::NewGuid()).inf"
try {
    secedit.exe /export /cfg $tempFile /quiet
    $privilegeLine = Get-Content $tempFile | Where-Object { $_.StartsWith("SeBackupPrivilege") }

    if ($privilegeLine) {
        $sidsString = $privilegeLine.Split('=', 2)[1].Trim()
        if (-not [string]::IsNullOrEmpty($sidsString)) {
            $accountNames = $sidsString.Split(',') | ForEach-Object {
                try {
                    $sid = New-Object System.Security.Principal.SecurityIdentifier($_.Trim())
                    $account = $sid.Translate([System.Security.Principal.NTAccount])
                    $account.Value.Split('\')[-1]
                }
                catch {
                    # SID could not be translated, so we skip it.
                }
            }
            $accountNames -join ','
        }
    }
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}