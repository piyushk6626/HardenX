$secpolfile = Join-Path $env:TEMP "secpol.inf"
try {
    secedit /export /cfg $secpolfile /quiet
    $sidsLine = Get-Content $secpolfile | Select-String -Pattern '^\s*SeInteractiveLogonRight'
    if ($sidsLine) {
        $sids = ($sidsLine.Line -split '=', 2)[1].Trim() -split ','
        $names = foreach ($sid in $sids) {
            $trimmedSid = $sid.Trim().TrimStart('*')
            if ([string]::IsNullOrWhiteSpace($trimmedSid)) { continue }
            try {
                $sidObj = [System.Security.Principal.SecurityIdentifier]$trimmedSid
                $account = $sidObj.Translate([System.Security.Principal.NTAccount])
                $account.Value.Split('\')[-1]
            } catch {}
        }
        $names -join ','
    }
}
finally {
    if (Test-Path $secpolfile) {
        Remove-Item $secpolfile -Force -ErrorAction SilentlyContinue
    }
}