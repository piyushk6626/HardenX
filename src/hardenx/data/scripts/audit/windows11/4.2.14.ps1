# Administrator privileges are recommended for querying service configurations to avoid any permission issues.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are recommended for this script. Please re-run in an elevated PowerShell terminal."
    exit 1
}

try {
    # Attempt to retrieve the 'upnphost' service object.
    # -ErrorAction Stop ensures that if the service is not found, the script will jump to the 'catch' block.
    $service = Get-Service -Name 'upnphost' -ErrorAction Stop
    
    # If the service is found, output its startup type as required.
    Write-Output $service.StartType
}
catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
    # This 'catch' block executes specifically when Get-Service cannot find the service.
    # If the service is not installed on the system, its state is functionally 'Disabled'.
    Write-Output "Disabled"
}
catch {
    # This is a general catch-all for any other unexpected errors.
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    exit 1
}