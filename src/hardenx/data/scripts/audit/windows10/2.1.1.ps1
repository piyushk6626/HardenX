$tempFile = [System.IO.Path]::GetTempFileName()
try {
    secedit.exe /export /cfg $tempFile /quiet
    $policyLine = Get-Content -Path $tempFile | Select-String -Pattern '^\s*SeTrustedCredManAccessPrivilege\s*=' -CaseSensitive
    
    if ($null -ne $policyLine) {
        $value = ($policyLine.Line.Split('=', 2)[1]).Trim()
        Write-Output $value
    }
    else {
        Write-Output ""
    }
}
finally {
    if (Test-Path -Path $tempFile) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}