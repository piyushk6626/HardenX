try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\Software\Policies\Microsoft\AppHVSI' -Name 'AllowFileDownload' -ErrorAction Stop
    if ($value -eq 1) {
        'Enabled'
    }
    else {
        'Disabled'
    }
}
catch {
    'Disabled'
}