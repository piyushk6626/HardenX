param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Accounts
)

$ErrorActionPreference = 'Stop'
$tempInfPath = $null
$tempSdbPath = $null

try {
    # Secedit requires SIDs, not account names. This block translates them.
    # The '*' prefix for each SID is required by the .inf file format for user rights.
    $sids = $Accounts.Split(',') | ForEach-Object {
        $trimmedAccount = $_.Trim()
        if (-not [string]::IsNullOrWhiteSpace($trimmedAccount)) {
            $account = New-Object System.Security.Principal.NTAccount($trimmedAccount)
            "*$($account.Translate([System.Security.Principal.SecurityIdentifier]).Value)"
        }
    }
    $sidString = $sids -join ','

    # Create temporary file paths for the security policy configuration and database
    $tempInfPath = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".inf")
    $tempSdbPath = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".sdb")

    # Create the content for the security policy .inf file
    $infContent = @"
[Unicode]
Unicode=yes
[Version]
signature = "`$CHICAGO`$"
Revision = 1
[Privilege Rights]
SeInteractiveLogonRight = $sidString
"@

    # Write the content to the temporary .inf file using Unicode encoding, which is required by secedit
    [System.IO.File]::WriteAllText($tempInfPath, $infContent, [System.Text.Encoding]::Unicode)

    # Configure the system security by importing the .inf file
    # We use Start-Process and wait for it to ensure it completes before we proceed.
    $process = Start-Process -FilePath "secedit.exe" -ArgumentList "/configure /db `"$tempSdbPath`" /cfg `"$tempInfPath`" /quiet" -Wait -PassThru -WindowStyle Hidden
    
    if ($process.ExitCode -ne 0) {
        throw "secedit.exe failed with exit code $($process.ExitCode)."
    }

    $true
}
catch {
    $false
}
finally {
    # Clean up the temporary files
    if ($tempInfPath -and (Test-Path $tempInfPath)) {
        Remove-Item $tempInfPath -Force -ErrorAction SilentlyContinue
    }
    if ($tempSdbPath -and (Test-Path $tempSdbPath)) {
        Remove-Item $tempSdbPath -Force -ErrorAction SilentlyContinue
    }
}