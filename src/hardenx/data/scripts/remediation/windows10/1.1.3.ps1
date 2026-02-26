[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateRange(0, 49710)]
    [int]$Days
)

try {
    net.exe accounts /minpwage:$Days *> $null
    # $? is $true if the last command's exit code was 0, otherwise $false.
    if ($?) {
        $true
    }
    else {
        $false
    }
}
catch {
    # Catches script-level errors (e.g., parameter validation, command not found).
    $false
}