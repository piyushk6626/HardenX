param (
    [Parameter(Mandatory = $true, Position = 0)]
    [int]$MaxPasswordAge
)

net accounts /maxpwage:$MaxPasswordAge | Out-Null

$LASTEXITCODE -eq 0