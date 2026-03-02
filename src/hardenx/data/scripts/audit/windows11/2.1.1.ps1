$tempFile = [System.IO.Path]::GetTempFileName()
try {
    secedit.exe /export /cfg $tempFile /areas USER_RIGHTS /quiet
    $privilegeLine = Get-Content $tempFile | Select-String -Pattern "SeTrustedCredManAccessPrivilege" -ErrorAction SilentlyContinue
    
    if ($null -ne $privilegeLine) {
        $principals = ($privilegeLine.Line.Split('=', 2)[1]).Trim()
    } else {
        $principals = $null
    }

    if ([string]::IsNullOrWhiteSpace($principals)) {
        Write-Output 'No One'
    } else {
        Write-Output $principals
    }
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}