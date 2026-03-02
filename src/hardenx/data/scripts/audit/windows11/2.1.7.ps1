# This script must be run with Administrator privileges to access security policies.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required. Please re-run this script in an elevated PowerShell terminal."
    # Exit with a non-zero code to indicate failure.
    exit 1
}

# Create a unique, temporary file path for the security policy export.
$tempFile = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".inf")

try {
    # Export only the User Rights Assignment area of the policy for efficiency.
    secedit.exe /export /cfg $tempFile /areas USER_RIGHTS /quiet

    # Verify that the export file was created and is not empty before proceeding.
    if (-NOT (Test-Path -Path $tempFile -PathType Leaf) -or (Get-Item $tempFile).Length -eq 0) {
        Write-Error "Failed to export security policy database. Cannot continue."
        exit 1
    }

    # Find the line for the 'Change the time zone' right (SeTimeZonePrivilege).
    # We MUST specify '-Encoding Unicode' because that's the format secedit uses.
    $settingMatch = Get-Content $tempFile -Encoding Unicode | Select-String -Pattern '^\s*SeTimeZonePrivilege\s*='

    # Initialize an array to hold the final, clean account names.
    $accountNames = @()

    # Only proceed if the setting was actually found in the file.
    if ($settingMatch) {
        # Safely extract the string of SIDs from the line.
        $sidsString = ($settingMatch.Line -split '=', 2)[1].Trim()

        # Check if the string is not empty before trying to process it.
        if (-not [string]::IsNullOrWhiteSpace($sidsString)) {
            # Split the string into individual SIDs.
            $sids = $sidsString -split '\s*,\s*'

            # Loop through each SID and translate it to a simple account name.
            $accountNames = foreach ($sid in $sids) {
                # Ensure the entry isn't empty before processing.
                if ($sid) {
                    try {
                        # THE KEY FIX: Remove the leading '*' from the SID string before creating the object.
                        $sidObject = New-Object System.Security.Principal.SecurityIdentifier($sid.TrimStart('*'))
                        # Translate the SID to an NT Account (e.g., NT AUTHORITY\LOCAL SERVICE).
                        $ntAccount = $sidObject.Translate([System.Security.Principal.NTAccount])
                        # Return ONLY the name part (e.g., 'LOCAL SERVICE').
                        $ntAccount.Value.Split('\')[-1]
                    }
                    catch {
                        # If a SID can't be translated, return the raw SID for debugging.
                        $sid
                    }
                }
            }
        }
    }

    # Output the final list of names, sorted alphabetically and joined by a comma, as required.
    Write-Output (($accountNames | Sort-Object) -join ',')
}
catch {
    # Catch any other unexpected script-breaking errors.
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
}
finally {
    # Always ensure the temporary file is deleted.
    if (Test-Path -Path $tempFile) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}