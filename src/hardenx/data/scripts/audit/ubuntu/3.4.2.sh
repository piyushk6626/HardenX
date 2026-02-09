#!/usr/bin/env bash

# Check if the service unit exists. `systemctl status` returns exit code 4 if not found.
systemctl status systemd-timesyncd &> /dev/null
if [[ $? -eq 4 ]]; then
    echo "Not Found"
    exit 0
fi

if systemctl is-enabled --quiet systemd-timesyncd; then
    if systemctl is-active --quiet systemd-timesyncd; then
        echo "Enabled and Active"
    else
        echo "Enabled but Inactive"
    fi
else
    echo "Disabled"
fi