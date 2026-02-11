#!/usr/bin/env bash

# Use systemctl to find the unit file. If it doesn't exist, it's not installed.
if ! systemctl list-unit-files --type=service | grep -q '^rsyslog\.service\s'; then
    echo "Not Installed"
    exit 0
fi

if systemctl is-enabled --quiet rsyslog; then
    if systemctl is-active --quiet rsyslog; then
        echo "Enabled and Active"
    else
        echo "Enabled but Inactive"
    fi
else
    echo "Disabled"
fi