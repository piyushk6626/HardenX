# Administrator privileges are required for reliable access to the HKEY_LOCAL_MACHINE (HKLM) hive.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required to query this registry setting. Please re-run this script in an elevated PowerShell terminal."
    exit 1
}

try {
    $registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    $propertyName = 'PasswordExpiryWarning'

    # Get-ItemPropertyValue is the most direct way to retrieve a single registry value.
    # It returns $null if the property doesn't exist, which we can check for.
    # -ErrorAction SilentlyContinue prevents an error if the path itself is missing.
    $value = Get-ItemPropertyValue -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

    if ($null -ne $value) {
        # If the value exists, output it.
        Write-Output $value
    }
    else {
        # If the registry value is not set, the Windows default is 14 days.
        # A proper audit should report this effective default value.
        Write-Output "14"
    }
}
catch {
    # This catches any other unexpected errors during the registry query.
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    exit 1
}