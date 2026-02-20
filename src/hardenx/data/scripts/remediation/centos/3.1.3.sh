#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

STATE="$1"

if [ "$STATE" == "disabled" ]; then
    if systemctl --now disable dhcpd &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi