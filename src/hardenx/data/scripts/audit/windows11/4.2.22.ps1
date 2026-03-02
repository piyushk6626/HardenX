$service = Get-Service -Name W3SVC -ErrorAction SilentlyContinue
if ($null -ne $service) {
    $service.StartType
}
else {
    'Not Installed'
}