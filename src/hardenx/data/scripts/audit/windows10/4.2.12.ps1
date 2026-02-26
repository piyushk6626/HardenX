if ((Get-WindowsOptionalFeature -Online -FeatureName 'Simple-TCPIP').State -eq 'Enabled') {
    (Get-Service -Name 'simptcp').StartType
}
else {
    'Not Installed'
}