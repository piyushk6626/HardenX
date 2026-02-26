try {
    (Get-Service -Name Browser -ErrorAction Stop).StartType
}
catch {
    'Not Installed'
}