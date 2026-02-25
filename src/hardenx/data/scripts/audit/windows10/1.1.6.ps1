$tempFile = Join-Path -Path $env:TEMP -ChildPath "LocalSecurityPolicy.inf"

try {
    # secedit.exe requires an existing file to write to in some environments.
    if (-not (Test-Path -Path $tempFile)) {
        New-Item -Path $tempFile -ItemType File -Force > $null
    }
    
    $process = Start-Process -FilePath "secedit.exe" -ArgumentList "/export /cfg `"$tempFile`" /quiet" -Wait -PassThru
    
    if ($process.ExitCode -ne 0) {
        # Silently exit if secedit fails, as no specific error output was requested.
        return
    }

    $settingLine = Get-Content -Path $tempFile | Select-String -Pattern '^\s*ClearTextPassword\s*=' -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($null -ne $settingLine) {
        $value = ($settingLine.Line -split '=')[1].Trim()
        if ($value -eq '0') {
            'Disabled'
        }
        elseif ($value -eq '1') {
            'Enabled'
        }
    }
}
finally {
    if (Test-Path -Path $tempFile) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}