param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Yes', 'No')]
    [string]$AllowMerge
)

try {
    $mergePolicy = ($AllowMerge -eq 'Yes')
    Set-NetFirewallProfile -Profile Public -AllowLocalIPsecPolicyMerge $mergePolicy -ErrorAction Stop
    $true
}
catch {
    $false
}