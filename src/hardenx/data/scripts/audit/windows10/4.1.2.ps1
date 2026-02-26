try {
    (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'ConsentPromptBehaviorAdmin' -ErrorAction Stop).ConsentPromptBehaviorAdmin
}
catch {
    5
}