$tempFile = Join-Path $env:TEMP "$(New-Guid).inf"
try {
    Start-Process -FilePath "secedit.exe" -ArgumentList "/export /cfg `"$tempFile`"" -Wait -WindowStyle Hidden -NoNewWindow
    if (Test-Path -Path $tempFile -PathType Leaf) {
        $privilegeLine = Get-Content -Path $tempFile | Where-Object { $_ -like 'SeTimeZonePrivilege*' }
        if ($null -ne $privilegeLine) {
            ($privilegeLine -split '=', 2)[1].Trim()
        }
    }
}
finally {
    if (Test-Path -Path $tempFile -PathType Leaf) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}