$value = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10' -Name 'Start' -ErrorAction SilentlyContinue
if ($null -ne $value) {
    $value
} else {
    'Not Found'
}