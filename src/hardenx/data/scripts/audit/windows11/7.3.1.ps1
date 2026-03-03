try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI' -Name 'VsmPersistency' -ErrorAction Stop
    switch ($value) {
        0 { 'Disabled' }
        1 { 'Enabled' }
    }
}
catch {
    'Not Configured'
}