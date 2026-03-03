param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$LogFilePath
)

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"
$valueName = "LogFilePath"

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
    }
    
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $LogFilePath -Type ExpandString -ErrorAction Stop
    
    return $true
}
catch {
    return $false
}