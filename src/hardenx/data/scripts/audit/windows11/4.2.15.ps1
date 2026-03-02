try {
    (Get-Service -Name 'WMSvc' -ErrorAction Stop).StartType
}
catch {
    'Not Installed'
}