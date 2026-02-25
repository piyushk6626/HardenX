$tempFile = [System.IO.Path]::GetTempFileName()
try {
    & secedit.exe /export /cfg $tempFile /quiet
    $content = Get-Content -Path $tempFile -Raw
    if ($content -match '(?m)^\s*MinimumPasswordLength\s*=\s*(\d+)') {
        $Matches[1]
    }
}
finally {
    if (Test-Path -LiteralPath $tempFile) {
        Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
    }
}