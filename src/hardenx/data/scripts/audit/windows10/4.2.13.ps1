$service = Get-Service -Name 'SNMP' -ErrorAction SilentlyContinue
if ($null -eq $service) {
    'Not Installed'
}
else {
    $service.StartType
}