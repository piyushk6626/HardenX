try {
    (Get-Service -Name 'RemoteAccess' -ErrorAction Stop).StartType
}
catch {
    'Not Found'
}