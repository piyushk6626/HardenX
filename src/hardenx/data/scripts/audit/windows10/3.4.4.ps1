try {
    $value = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' -Name 'NtlmMinClientSec' -ErrorAction Stop
    $value
}
catch {
    '0'
}