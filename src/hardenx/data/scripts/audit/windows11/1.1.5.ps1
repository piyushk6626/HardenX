$tempFile = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
secedit.exe /export /cfg $tempFile /quiet | Out-Null
try {
    $settingLine = Get-Content $tempFile | Select-String -Pattern "PasswordComplexity" -ErrorAction SilentlyContinue
    if ($settingLine -and $settingLine.Line.Trim().EndsWith("1")) {
        "Enabled"
    } else {
        "Disabled"
    }
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}