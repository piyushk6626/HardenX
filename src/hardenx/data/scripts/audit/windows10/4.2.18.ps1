try {
    (Get-Service -Name 'WMPNetworkSvc' -ErrorAction Stop).StartType
}
catch {
    'Not Installed'
}