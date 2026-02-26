[CmdletBinding(DefaultParameterSetName='Default')]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "A comma-separated string of principals to grant the user right to.")]
    [string]$Principals
)

$ErrorActionPreference = 'Stop'
$privilegeName = 'SeIncreaseQuotaPrivilege'
$tempPath = $env:TEMP
$infFile = Join-Path -Path $tempPath -ChildPath "SecPolicy.inf"
$sdbFile = Join-Path -Path $tempPath -ChildPath "SecPolicy.sdb"

try {
    # Check for elevated privileges by attempting to create a file in a restricted directory
    $testFile = Join-Path -Path $env:SystemRoot -ChildPath "temp.tmp"
    New-Item -Path $testFile -ItemType File -Force > $null
    Remove-Item -Path $testFile -Force

    # Export the current local security policy
    secedit.exe /export /cfg $infFile /quiet
    if (-not $?) { throw "Failed to export security policy." }

    # Read the exported policy and prepare the new line
    $policyContent = Get-Content -Path $infFile -Raw
    $newLine = "$privilegeName = $Principals"

    # Check if the privilege is already defined
    if ($policyContent -match "(?m)^$privilegeName\s*=.*") {
        # If it exists, replace the existing line
        $newContent = $policyContent -replace "(?m)^$privilegeName\s*=.*", $newLine
    }
    else {
        # If it doesn't exist, add it under the [Privilege Rights] section
        $sectionHeader = '[Privilege Rights]'
        if ($policyContent -match [regex]::Escape($sectionHeader)) {
             $newContent = $policyContent -replace [regex]::Escape($sectionHeader), "$sectionHeader`r`n$newLine"
        }
        else {
            # This case is unlikely but handled for robustness
            $newContent = "$policyContent`r`n$sectionHeader`r`n$newLine"
        }
    }

    # Write the modified content to the INF file
    Set-Content -Path $infFile -Value $newContent -Force

    # Import the modified policy
    secedit.exe /configure /db $sdbFile /cfg $infFile /areas USER_RIGHTS /quiet
    if (-not $?) { throw "Failed to import security policy." }
    
    # Return success
    $true
}
catch {
    # Return failure
    $false
}
finally {
    # Clean up temporary files
    if (Test-Path -Path $infFile) {
        Remove-Item -Path $infFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path $sdbFile) {
        Remove-Item -Path $sdbFile -Force -ErrorAction SilentlyContinue
    }
}