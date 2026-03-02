$tempFile = [System.IO.Path]::GetTempFileName()
try {
    secedit.exe /export /cfg $tempFile /quiet
    $settingLine = Get-Content -Path $tempFile | Select-String -Pattern "^\s*LockoutDuration\s*="
    if ($null -ne $settingLine) {
        $value = ($settingLine.Line -split '=')[1].Trim()
        [int]$value
    }
}
finally {
    if (Test-Path -Path $tempFile) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}