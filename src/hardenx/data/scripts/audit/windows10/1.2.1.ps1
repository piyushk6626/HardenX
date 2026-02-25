$tempCfgFile = Join-Path -Path $env:TEMP -ChildPath ([System.IO.Path]::GetRandomFileName() + ".inf")
try {
    secedit.exe /export /cfg "$tempCfgFile" /quiet
    if (Test-Path $tempCfgFile -PathType Leaf) {
        $match = Select-String -Path $tempCfgFile -Pattern '^\s*LockoutDuration\s*=\s*(\d+)'
        if ($null -ne $match) {
            $match.Matches[0].Groups[1].Value
        }
    }
}
finally {
    if (Test-Path $tempCfgFile -PathType Leaf) {
        Remove-Item -Path $tempCfgFile -Force -ErrorAction SilentlyContinue
    }
}