$regValue = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\AppHVSI' -Name 'AllowCameraMicrophoneRedirection' -ErrorAction SilentlyContinue

if ($null -ne $regValue -and $regValue.AllowCameraMicrophoneRedirection -eq 1) {
    '1'
}
else {
    '0'
}