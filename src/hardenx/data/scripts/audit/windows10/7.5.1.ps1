try {
    Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI' -Name 'ClipboardOptions' -ErrorAction Stop
}
catch {
    0
}