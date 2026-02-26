[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$AccountNames
)

$success = $false
$tempInf = $null
$tempSdb = $null
$logFile = $null

try {
    $sids = @()
    $accounts = $AccountNames.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    if ($accounts.Count -eq 0) {
        # No valid accounts specified, treat as failure.
        throw
    }

    foreach ($account in $accounts) {
        try {
            $ntAccount = New-Object System.Security.Principal.NTAccount($account)
            $sids += $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
        }
        catch {
            # If any single account fails translation, the entire operation fails.
            throw
        }
    }
    
    $tempInf = [System.IO.Path]::GetTempFileName()
    $tempSdb = [System.IO.Path]::GetTempFileName()
    $logFile = [System.IO.Path]::GetTempFileName()
    Remove-Item $tempSdb, $logFile -Force # Secedit requires these files not to exist initially

    # Export the current policy
    secedit.exe /export /cfg $tempInf /quiet
    if ($LASTEXITCODE -ne 0) {
        throw
    }

    $configContent = Get-Content -Path $tempInf -Raw -Encoding Unicode
    $privilegeName = "SeBackupPrivilege"
    $sidString = ($sids | ForEach-Object { "*$_" }) -join ','
    $newLine = "$privilegeName = $sidString"
    
    # Check if the privilege is already defined
    if ($configContent -match "(?im)^$privilegeName\s*=\s*.*$") {
        # If it exists, replace it
        $configContent = $configContent -replace "(?im)^$privilegeName\s*=\s*.*$", $newLine
    }
    # Check if the [Privilege Rights] section exists
    elseif ($configContent -match "(?im)^\[Privilege Rights\]") {
        # If it exists, add the new privilege to it
        $configContent = $configContent -replace "(?im)^(\[Privilege Rights\])", "`$1`r`n$newLine"
    }
    # If neither the privilege nor the section exists
    else {
        # Add the section and the privilege
        $configContent = $configContent + "`r`n`r`n[Privilege Rights]`r`n$newLine"
    }

    $configContent | Set-Content -Path $tempInf -Encoding Unicode -NoNewline
    
    # Configure the system with the new policy
    secedit.exe /configure /db $tempSdb /cfg $tempInf /log $logFile /quiet
    if ($LASTEXITCODE -eq 0) {
        $success = $true
    }
}
catch {
    $success = $false
}
finally {
    # Clean up temporary files
    if ($null -ne $tempInf -and (Test-Path $tempInf)) {
        Remove-Item $tempInf -Force -ErrorAction SilentlyContinue
    }
    if ($null -ne $tempSdb -and (Test-Path $tempSdb)) {
        Remove-Item $tempSdb -Force -ErrorAction SilentlyContinue
    }
    if ($null -ne $logFile -and (Test-Path $logFile)) {
        Remove-Item $logFile -Force -ErrorAction SilentlyContinue
    }
}

$success