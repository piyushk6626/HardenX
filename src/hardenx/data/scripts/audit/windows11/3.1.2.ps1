# It's best practice for audit scripts to run with elevated privileges.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required for guaranteed accuracy. Please re-run this script in an elevated PowerShell terminal."
    exit 1
}

try {
    # Attempt to retrieve the 'Guest' user account.
    # -ErrorAction Stop ensures that if the user isn't found, the script jumps to the 'catch' block.
    $guestAccount = Get-LocalUser -Name 'Guest' -ErrorAction Stop

    # Check the 'Enabled' property and output the required string.
    if ($guestAccount.Enabled) {
        Write-Output "Enabled"
    }
    else {
        Write-Output "Disabled"
    }
}
catch [Microsoft.PowerShell.Commands.UserNotFoundException] {
    # This 'catch' block runs specifically if the 'Guest' account does not exist.
    # If the account doesn't exist, it is functionally disabled, so we report it as such.
    Write-Output "Disabled"
}
catch {
    # This catches any other unexpected errors during the command's execution.
    Write-Error "An unexpected error occurred while querying the Guest account: $($_.Exception.Message)"
    exit 1
}