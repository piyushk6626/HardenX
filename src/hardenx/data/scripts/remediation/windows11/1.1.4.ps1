param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateRange(0, 14)]
    [int]$MinPasswordLength
)

# Suppress all output streams from the external command
net.exe accounts /minpwlen:$MinPasswordLength *>&1 | Out-Null

# Check the success of the last command and return the appropriate boolean value
if ($LASTEXITCODE -eq 0) {
    return $true
}
else {
    return $false
}