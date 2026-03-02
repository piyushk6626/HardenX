# Administrator privileges are required to use Get-WindowsOptionalFeature -Online.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required to query Windows features. Please re-run this script in an elevated PowerShell terminal."
    exit 1
}

try {
    # Attempt to get the status of the SimpleTCPServices optional feature.
    $feature = Get-WindowsOptionalFeature -Online -FeatureName 'SimpleTCPServices' -ErrorAction Stop

    # The feature's 'State' is 'Disabled' when not installed, and 'Enabled' when installed.
    if ($feature.State -eq 'Enabled') {
        # If the feature IS installed, we must check the status of the 'simptcp' service.
        try {
            $service = Get-Service -Name 'simptcp' -ErrorAction Stop
            # Check the StartType property of the service.
            if ($service.StartType -eq 'Disabled') {
                Write-Output 'Disabled'
            }
            else {
                # If the service is not explicitly disabled (e.g., it's 'Manual' or 'Automatic'), it is considered 'Enabled'.
                Write-Output 'Enabled'
            }
        }
        catch {
            # This handles a rare case where the feature is installed but the service is missing or unreadable.
            # This is an unhealthy state, so we fail "insecurely" by reporting 'Enabled' to ensure it gets flagged for remediation.
            Write-Output 'Enabled'
        }
    }
    else {
        # If the feature's State is 'Disabled', it means it is not installed on the system.
        Write-Output 'Not Installed'
    }
}
catch {
    # This top-level catch runs if the Get-WindowsOptionalFeature command itself fails.
    # We "fail-secure" by assuming the feature is not installed if we cannot verify its status.
    Write-Output 'Not Installed'
}