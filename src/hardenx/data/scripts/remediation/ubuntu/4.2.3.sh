#!/bin/bash

if [[ $# -ne 1 || "$1" != "Not Available" ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONF_FILE="/etc/modprobe.d/blacklist-rds.conf"
CONF_CONTENT="install rds /bin/true"

# Unload the module if it is loaded
if lsmod | grep -q "^rds "; then
    if ! rmmod rds; then
        echo "false"
        exit 1
    fi
fi

# Create the configuration file to prevent future loading
if ! echo "$CONF_CONTENT" > "$CONF_FILE"; then
    echo "false"
    exit 1
fi

echo "true"
exit 0