#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 || "$1" != "disabled" ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONF_FILE="/etc/modprobe.d/disable-rds.conf"

# Create the modprobe configuration to disable the module
echo "install rds /bin/true" > "$CONF_FILE"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Unload the module if it's currently loaded
if lsmod | grep -qw rds; then
    rmmod rds
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0