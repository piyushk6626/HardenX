$secpolFile = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".inf")
try {
    secedit.exe /export /cfg $secpolFile /quiet
    if (Test-Path $secpolFile) {
        ((Get-Content $secpolFile) | Select-String -Pattern "PasswordHistorySize").Line.Split("=")[1].Trim()
    }
}
finally {
    if (Test-Path $secpolFile) {
        Remove-Item $secpolFile -Force -ErrorAction SilentlyContinue
    }
}