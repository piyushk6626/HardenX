param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$State
)

try {
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $regName = 'FilterAdministratorToken'
    $valueToSet = $null

    switch ($State) {
        'Enabled' {
            $valueToSet = 1
        }
        'Disabled' {
            $valueToSet = 0
        }
        default {
            $false
            return
        }
    }

    Set-ItemProperty -Path $regPath -Name $regName -Value $valueToSet -Type DWord -Force
    
    $true
}
catch {
    $false
}