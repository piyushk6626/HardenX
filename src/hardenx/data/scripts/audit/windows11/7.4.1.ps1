try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\Software\Policies\Microsoft\AppHVSI' -Name 'AllowFileDownloads' -ErrorAction Stop
    if ($value -eq 0) {
        'Disabled'
    } else {
        'Enabled'
    }
}
catch {
    'Enabled'
}