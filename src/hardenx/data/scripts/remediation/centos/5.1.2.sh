#!/bin/bash

if [[ "$1" == "Not Installed" ]]; then
    if yum remove -y iptables-services &>/dev/null; then
        exit 0
    else
        exit 1
    fi
fi

exit 0