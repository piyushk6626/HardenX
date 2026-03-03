# The auditpol.exe command requires administrator privileges to run.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required to query audit policies. Please re-run this script in an elevated PowerShell terminal."
    exit 1
}

try {
    # UPDATED PATTERN: This regex now looks for the line containing "Removable Storage"
    # and captures the text in the "Setting" column that follows it.
    $pattern = '^\s*Removable Storage\s+(.+)'

    # Run the auditpol command and pipe its output to find the relevant line.
    $matchInfo = auditpol.exe /get /subcategory:"Removable Storage" | Select-String -Pattern $pattern
    
    # Check if a matching line was found.
    if ($matchInfo) {
        # The captured text (e.g., "No Auditing") is in the first "Group" of the first "Match".
        Write-Output $matchInfo.Matches[0].Groups[1].Value.Trim()
    }
}
catch {
    # This block will catch any errors if auditpol.exe fails to run.
    Write-Error "An error occurred while querying the audit policy: $($_.Exception.Message)"
    exit 1
}