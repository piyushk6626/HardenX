if ((Get-LocalUser -Name 'Guest').Enabled) {
    'Enabled'
}
else {
    'Disabled'
}