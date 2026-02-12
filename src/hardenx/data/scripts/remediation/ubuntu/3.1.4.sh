#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ "$1" == "Not Installed" ]]; then
    if apt-get purge -y bind9 dnsmasq &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "true"
fi