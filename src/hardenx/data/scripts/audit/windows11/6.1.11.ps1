# The auditpol.exe command requires administrator privileges to run.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required to query audit policies. Please re-run this script in an elevated PowerShell terminal."
    exit 1
}

try {
    # Get the policy as a CSV and convert it to a PowerShell object.
    $auditPolicyObject = auditpol.exe /get /subcategory:"Audit Policy Change" /r | ConvertFrom-Csv
    
    if ($null -ne $auditPolicyObject) {
        # CORRECTED INDEX: The 'Inclusion Setting' is the fifth column, which has an index of [4].
        $propertyName = $auditPolicyObject.psobject.Properties.Name[4]
        
        # Use the dynamically found property name to get the correct value.
        $settingValue = $auditPolicyObject.$propertyName
        
        Write-Output $settingValue
    }
}
catch {
    # This block will catch any errors if auditpol.exe fails to run.
    Write-Error "An error occurred while querying the audit policy: $($_.Exception.Message)"
    exit 1
}