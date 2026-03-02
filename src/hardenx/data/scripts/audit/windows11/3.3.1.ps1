try {
    (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters' -ErrorAction Stop).autodisconnect
}
catch {
    '15'
}