param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled', IgnoreCase = $true)]
    [string]$State
)

$tempInf = $null
$tempSdb = $null
$success = $false

try {
    # This script requires administrative privileges to run secedit.exe
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Administrator privileges are required to modify security policies."
    }

    $value = if ($State -eq 'Enabled') { 1 } else { 0 }

    $tempInf = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName() + ".inf")
    $tempSdb = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName() + ".sdb")

    # The dollar sign in `$CHICAGO$` must be escaped with a backtick for the here-string
    $infContent = @"
[Unicode]
Unicode=yes
[System Access]
ClearTextPassword = $value
[Version]
signature="`$CHICAGO`$"
Revision=1
"@

    Set-Content -Path $tempInf -Value $infContent -Encoding Unicode -Force

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "secedit.exe"
    $processInfo.Arguments = "/configure /db `"$tempSdb`" /cfg `"$tempInf`" /quiet"
    $processInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $processInfo.CreateNoWindow = $true
    $processInfo.UseShellExecute = $false

    $process = [System.Diagnostics.Process]::Start($processInfo)
    $process.WaitForExit()

    if ($process.ExitCode -eq 0) {
        $success = $true
    }
}
catch {
    # Any exception will leave $success as $false
}
finally {
    if ($tempInf -and (Test-Path $tempInf)) {
        Remove-Item -Path $tempInf -Force -ErrorAction SilentlyContinue
    }
    if ($tempSdb -and (Test-Path $tempSdb)) {
        Remove-Item -Path $tempSdb -Force -ErrorAction SilentlyContinue
    }
}

return $success