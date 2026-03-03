try {
    Set-Service -Name WinRM -StartupType $args[0] -ErrorAction Stop
    $true
}
catch {
    $false
}