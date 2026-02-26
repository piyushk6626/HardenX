try {
    (Get-Service -Name W3SVC -ErrorAction Stop).StartType
}
catch {
    'Not Installed'
}