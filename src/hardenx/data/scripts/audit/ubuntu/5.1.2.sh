#!/bin/bash

UFW_STATUS=$(dpkg-query -W -f='${Status}' ufw 2>/dev/null)
IPTABLES_STATUS=$(dpkg-query -W -f='${Status}' iptables-persistent 2>/dev/null)

ufw_installed=false
if [[ "$UFW_STATUS" == "install ok installed" ]]; then
    ufw_installed=true
fi

iptables_installed=false
if [[ "$IPTABLES_STATUS" == "install ok installed" ]]; then
    iptables_installed=true
fi

if $ufw_installed && ! $iptables_installed; then
    echo "UFW Only"
elif ! $ufw_installed && $iptables_installed; then
    echo "Iptables Only"
elif $ufw_installed && $iptables_installed; then
    echo "Conflict"
else
    echo "None"
fi