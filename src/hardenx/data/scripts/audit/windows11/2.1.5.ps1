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

    # Find the line for the 'Back up files and directories' right (SeBackupPrivilege).
    # We MUST specify '-Encoding Unicode' because that's the format secedit uses.
    $settingMatch = Get-Content $tempFile -Encoding Unicode | Select-String -Pattern '^\s*SeBackupPrivilege\s*='

    # Initialize an array to hold the final, clean account names.
    $accountNames = @()

    # Only proceed if the setting was actually found in the file.
    if ($settingMatch) {
        # Safely extract the string of principals (SIDs or names).
        $principalsString = ($settingMatch.Line -split '=', 2)[1].Trim()

        # Check if the string is not empty before trying to process it.
        if (-not [string]::IsNullOrWhiteSpace($principalsString)) {
            # Split the string into individual principals.
            $principals = $principalsString -split '\s*,\s*'

            # Loop through each principal to resolve it to a simple name.
            $accountNames = foreach ($principal in $principals) {
                # The principal could be a SID (starts with '*') or already a name.
                if ($principal.StartsWith('*')) {
                    # This is a SID, so we translate it.
                    try {
                        # Create a SID object, removing the leading '*' character.
                        $sid = New-Object System.Security.Principal.SecurityIdentifier($principal.Substring(1))
                        # Translate the SID to an NT Account (e.g., BUILTIN\Administrators).
                        $ntAccount = $sid.Translate([System.Security.Principal.NTAccount])
                        # Return ONLY the name part (e.g., 'Administrators').
                        $ntAccount.Value.Split('\')[-1]
                    } catch {
                        # If translation fails, return the original SID string.
                        $principal
                    }
                } else {
                    # This is already a name, but it might include a domain (e.g., BUILTIN\Backup Operators).
                    # We return ONLY the name part to keep the output consistent.
                    $principal.Split('\')[-1]
                }
            }
        }
    }

    # Output the final, comma-separated list of names as required.
    # If no accounts were found, this correctly outputs an empty line.
    Write-Output ($accountNames -join ',')
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