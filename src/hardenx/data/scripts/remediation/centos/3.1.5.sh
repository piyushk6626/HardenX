#!/usr/bin/env bash

if [[ "$#" -ne 1 || "$1" != "disabled" ]]; then
    echo "false"
    exit 1
fi

if systemctl stop dnsmasq &>/dev/null && systemctl disable dnsmasq &>/dev/null; then
    echo "true"
else
    echo "false"
fi