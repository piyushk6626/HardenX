param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

try {
    $complexityValue = switch ($State) {
        'Enabled'  { 'YES' }
        'Disabled' { 'NO' }
    }

    # Suppress output from net.exe to keep the script's output clean
    net.exe accounts /COMPLEXITY:$complexityValue | Out-Null

    if ($LASTEXITCODE -eq 0) {
        return $true
    }
    else {
        # Force a terminating error to be caught
        throw "net.exe command failed with exit code $LASTEXITCODE"
    }
}
catch {
    return $false
}