#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

VALUE=$1

if [[ ! "$VALUE" =~ ^[01]$ ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/sysctl.d/99-ip-forward.conf"

if ! sysctl -w net.ipv4.ip_forward="$VALUE" &>/dev/null; then
    echo "false"
    exit 1
fi

if ! echo "net.ipv4.ip_forward = $VALUE" > "$CONFIG_FILE"; then
    echo "false"
    exit 1
fi

echo "true"
exit 0