$secpolFile = Join-Path -Path $env:TEMP -ChildPath "secpol.inf"
try {
    secedit.exe /export /cfg $secpolFile /quiet
    $policyLine = Get-Content -Path $secpolFile | Where-Object { $_.StartsWith("SeNetworkLogonRight") }
    if ($null -ne $policyLine) {
        $sidsAndNames = $policyLine.Split('=', 2)[1].Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        $resolvedNames = foreach ($item in $sidsAndNames) {
            if ($item.StartsWith('*')) {
                try {
                    $sid = New-Object System.Security.Principal.SecurityIdentifier($item.Substring(1))
                    $account = $sid.Translate([System.Security.Principal.NTAccount]).Value
                    ($account -split '\\', 2)[-1]
                }
                catch {
                    $item.Substring(1)
                }
            }
            else {
                $item
            }
        }
        $resolvedNames -join ','
    }
}
finally {
    if (Test-Path -Path $secpolFile) {
        Remove-Item -Path $secpolFile -Force -ErrorAction SilentlyContinue
    }
}