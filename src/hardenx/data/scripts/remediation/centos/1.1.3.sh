#!/usr/bin/env bash


if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONF_FILE="/etc/modprobe.d/hfs.conf"

if ! echo "install hfs /bin/true" > "$CONF_FILE"; then
    echo "false"
    exit 1
fi

# Check if the module is currently loaded before attempting to remove it
if lsmod | grep -q "^hfs\s"; then
    if ! rmmod hfs; then
        # If removal fails, the configuration is incomplete/failed.
        # Clean up the created file and report failure.
        rm -f "$CONF_FILE"
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0
