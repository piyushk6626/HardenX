if ((Get-NetFirewallProfile -Profile Private).NotifyOnListen) {
    Write-Host "Yes"
} else {
    Write-Host "No"
}