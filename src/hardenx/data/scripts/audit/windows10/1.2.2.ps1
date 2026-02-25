$tempFile = [System.IO.Path]::GetTempFileName()
try {
    secedit.exe /export /cfg $tempFile /quiet
    $settingLine = (Get-Content $tempFile) -match '^\s*LockoutBadCount\s*='
    if ($settingLine) {
        ($settingLine -split '=')[1].Trim()
    }
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}