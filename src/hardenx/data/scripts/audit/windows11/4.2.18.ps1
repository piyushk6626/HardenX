# Administrator privileges are recommended for querying service configurations to avoid any permission issues.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are recommended for this script. Please re-run in an elevated PowerShell terminal."
    exit 1
}

try {
    # Attempt to retrieve the 'WMPNetworkSvc' service object.
    # -ErrorAction Stop ensures that if the service isn't found, the script jumps to the 'catch' block.
    $service = Get-Service -Name 'WMPNetworkSvc' -ErrorAction Stop
    
    # If the service is found, output its startup type as required.
    Write-Output $service.StartType
}
catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
    # This 'catch' block executes specifically when Get-Service cannot find the service.
    # As per the requirements, this means the service is 'Not Installed'.
    Write-Output "Not Installed"
}
catch {
    # This is a general catch-all for any other unexpected errors.
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    exit 1
}