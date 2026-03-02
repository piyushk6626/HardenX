
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required. Please re-run this script in an elevated PowerShell terminal."
    exit 1
}

$tempFile = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".inf")

try {
    secedit.exe /export /cfg $tempFile /quiet

    if (-NOT (Test-Path -Path $tempFile -PathType Leaf) -or (Get-Item $tempFile).Length -eq 0) {
        Write-Error "Failed to export security policy database."
        exit 1
    }

    $numericValue = "0"

    $settingLine = Get-Content $tempFile -Encoding Unicode | Select-String -Pattern '^\s*EnableAdminAccountLockout\s*='

    if ($settingLine) {
        $numericValue = ($settingLine.Line -split '=')[1].Trim()
    }

    if ($numericValue -eq '1') {
        Write-Output "Enabled"
    }
    else {
        Write-Output "Disabled"
    }
}
finally {
    if (Test-Path -Path $tempFile) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}