param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('Enabled', 'Disabled')]
    [string]$State
)

try {
    $thresholdValue = 0
    if ($State -eq 'Enabled') {
        $thresholdValue = 5
    }

    # Execute the command and suppress any output from net.exe itself.
    net accounts /lockoutthreshold:$thresholdValue *> $null

    # Check the exit code of the last native command.
    if ($LASTEXITCODE -eq 0) {
        return $true
    } else {
        return $false
    }
}
catch {
    # Catch any unexpected script-terminating errors.
    return $false
}