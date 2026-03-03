# The Get-NetFirewallProfile cmdlet requires administrator privileges to run.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required to query firewall profiles. Please re-run this script in an elevated PowerShell terminal."
    exit 1
}

try {
    # Retrieve the 'Private' firewall profile object.
    $profile = Get-NetFirewallProfile -Name 'Private' -ErrorAction Stop
    
    # CORRECTED: Use the 'LogMaxSizeKilobytes' property.
    Write-Output $profile.LogMaxSizeKilobytes
}
catch {
    # This block will catch any errors.
    Write-Error "An error occurred while querying the firewall profile: $($_.Exception.Message)"
    exit 1
}