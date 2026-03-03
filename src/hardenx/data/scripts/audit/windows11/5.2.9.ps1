# The Get-NetFirewallProfile cmdlet requires administrator privileges to run.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required to query firewall profiles. Please re-run this script in an elevated PowerShell terminal."
    exit 1
}

try {
    # Retrieve the 'Public' firewall profile object.
    $profile = Get-NetFirewallProfile -Name 'Public' -ErrorAction Stop
    
    # NOTE: While the remediation command uses '-LogDroppedPackets', the corresponding 'Get'
    # command returns this value under the 'LogBlocked' property. We use 'LogBlocked' here
    # to accurately report the system's current state.
    Write-Output $profile.LogBlocked
}
catch {
    # This block will catch any errors.
    Write-Error "An error occurred while querying the firewall profile: $($_.Exception.Message)"
    exit 1
}