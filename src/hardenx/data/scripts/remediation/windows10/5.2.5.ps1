param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Action
)

try {
    $RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile'
    $ValueName = 'AllowLocalPolicyMerge'
    $RegValue = $null

    switch ($Action.ToLower()) {
        'yes' {
            $RegValue = 1
        }
        'no' {
            $RegValue = 0
        }
        default {
            return $false
        }
    }
    
    New-ItemProperty -Path $RegistryPath -Name $ValueName -Value $RegValue -PropertyType DWord -Force -ErrorAction Stop | Out-Null
    
    return $true
}
catch {
    return $false
}