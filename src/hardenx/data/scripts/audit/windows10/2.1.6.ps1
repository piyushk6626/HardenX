$tempFile = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
try {
    secedit.exe /export /cfg "$tempFile" /quiet | Out-Null
    $privilegeLine = Get-Content -Path $tempFile | Select-String -Pattern '^\s*SeSystemtimePrivilege\s*=' -ErrorAction SilentlyContinue

    if ($null -ne $privilegeLine) {
        $sidsAndNames = $privilegeLine.Line.Split('=', 2)[1].Trim().Split(',') | ForEach-Object { $_.Trim() }
        
        $resolvedNames = foreach ($item in $sidsAndNames) {
            if ($item -like '*S-1-*') {
                try {
                    $sid = New-Object System.Security.Principal.SecurityIdentifier ($item.TrimStart('*'))
                    $accountName = $sid.Translate([System.Security.Principal.NTAccount]).Value
                    $accountName.Split('\')[-1]
                } catch {
                    $item 
                }
            } else {
                $item
            }
        }
        $resolvedNames -join ','
    }
}
finally {
    if (Test-Path -Path $tempFile -PathType Leaf) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}