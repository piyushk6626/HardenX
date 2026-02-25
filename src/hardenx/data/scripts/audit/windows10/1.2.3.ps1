$tempFile = $null
try {
    $tempFile = [System.IO.Path]::GetTempFileName()
    secedit /export /cfg $tempFile /quiet
    $settingLine = Get-Content $tempFile | Where-Object { $_.StartsWith("LockoutBadCount") }
    $thresholdValue = ($settingLine -split '=')[1].Trim()
    
    if ([int]$thresholdValue -gt 0) {
        'Enabled'
    } else {
        'Disabled'
    }
}
finally {
    if ($null -ne $tempFile -and (Test-Path $tempFile)) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}
```