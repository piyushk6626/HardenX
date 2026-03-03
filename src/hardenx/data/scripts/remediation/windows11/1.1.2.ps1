param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateRange(1,999)]
    [int]$Days
)

try {
    net accounts /maxpwage:$Days | Out-Null
    # $? contains the execution status of the last command. True for success (exit code 0).
    return $?
}
catch {
    # Any script-terminating error (like parameter validation failure) or other exception.
    return $false
}