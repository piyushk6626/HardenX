$tempFile = [System.IO.Path]::GetTempFileName()
try {
    secedit /export /cfg $tempFile /quiet | Out-Null
    $settingLine = Get-Content $tempFile | Where-Object { $_.Trim().StartsWith('ClearTextPassword') }
    if ($null -ne $settingLine) {
        $value = ($settingLine.Split('=', 2)[1]).Trim()
        if ($value -eq '1') {
            'Enabled'
        }
        elseif ($value -eq '0') {
            'Disabled'
        }
    }
}
finally {
    if (Test-Path -Path $tempFile) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}