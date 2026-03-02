$logPath = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging' -Name 'LogFilePath' -ErrorAction SilentlyContinue
if ($logPath) {
    [System.Environment]::ExpandEnvironmentVariables($logPath)
} else {
    ""
}