$tempCfg = [System.IO.Path]::GetTempFileName()
$tempLog = [System.IO.Path]::GetTempFileName()

try {
    secedit.exe /export /cfg $tempCfg /log $tempLog /quiet
    
    $policyLine = Get-Content -Path $tempCfg -Encoding Unicode | Where-Object { $_.TrimStart() -like 'SeNetworkLogonRight *=' }

    if ($null -ne $policyLine) {
        $sidsString = ($policyLine -split '=', 2)[1].Trim()
        Write-Host -NoNewline $sidsString
    }
}
finally {
    if (Test-Path $tempCfg) { Remove-Item $tempCfg -Force -ErrorAction SilentlyContinue }
    if (Test-Path $tempLog) { Remove-Item $tempLog -Force -ErrorAction SilentlyContinue }
}