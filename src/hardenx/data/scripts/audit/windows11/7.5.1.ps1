$path = 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI'
$name = 'ClipboardRedirection'

try {
    (Get-ItemProperty -Path $path -Name $name -ErrorAction Stop).$name
}
catch {
    'Not Configured'
}