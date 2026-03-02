$tempFile = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
try {
    secedit.exe /export /cfg $tempFile /quiet | Out-Null
    $settingLine = Get-Content -Path $tempFile | Where-Object { $_.TrimStart().StartsWith("PasswordHistorySize") }
    if ($settingLine) {
        ($settingLine -split '=')[1].Trim()
    }
}
finally {
    if (Test-Path -Path $tempFile) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}