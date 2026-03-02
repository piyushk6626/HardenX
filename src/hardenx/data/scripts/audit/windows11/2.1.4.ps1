# This script MUST be run with Administrator privileges to access security policies.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required. Please re-run this script in an elevated PowerShell terminal."
    # Exit with a non-zero code to indicate failure.
    exit 1
}

# Create a unique, temporary file path for the security policy export.
$tempFile = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString() + ".inf")

try {
    # Export the current local security policy to the temp file.
    secedit.exe /export /cfg $tempFile /quiet

    # Verify that the export file was created and is not empty before proceeding.
    if (-NOT (Test-Path -Path $tempFile -PathType Leaf) -or (Get-Item $tempFile).Length -eq 0) {
        Write-Error "Failed to export security policy database. Cannot continue."
        exit 1
    }

    # Find the line for the 'Allow log on locally' right.
    # We MUST specify '-Encoding Unicode' because that's the format secedit uses.
    $settingMatch = Get-Content $tempFile -Encoding Unicode | Select-String -Pattern '^\s*SeInteractiveLogonRight\s*='

    # Initialize an array to hold the account names.
    $accountNames = @()

    # Only proceed if the setting was actually found in the file.
    if ($settingMatch) {
        # Safely extract the SID string by splitting the line at '=' and taking the second part.
        $sidsString = ($settingMatch.Line -split '=', 2)[1].Trim()

        # Check if the SID string is not empty before trying to process it.
        if (-not [string]::IsNullOrWhiteSpace($sidsString)) {
            # Split the string into individual SIDs.
            $sids = $sidsString -split '\s*,\s*'

            # Loop through each SID and translate it to a simple account name.
            $accountNames = foreach ($sid in $sids) {
                # Ensure the entry isn't empty before processing.
                if ($sid) {
                    try {
                        # Create a SID object, removing the leading '*' character.
                        $sidObject = New-Object System.Security.Principal.SecurityIdentifier($sid.TrimStart('*'))
                        # Translate the SID to an NT Account (e.g., BUILTIN\Administrators).
                        $ntAccount = $sidObject.Translate([System.Security.Principal.NTAccount])
                        # Return just the final part of the name (e.g., 'Administrators').
                        $ntAccount.Value.Split('\')[-1]
                    }
                    catch {
                        # If a SID can't be translated (e.g., from a deleted account), return the raw SID.
                        $sid
                    }
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