#!/bin/bash

# Check for installation using common package managers
if command -v dpkg &>/dev/null; then
    # Debian/Ubuntu style
    if ! dpkg -s chrony &>/dev/null; then
        echo "Not Installed"
        exit 0
    fi
    SERVICE_NAME="chrony"
elif command -v rpm &>/dev/null; then
    # RHEL/CentOS style
    if ! rpm -q chrony &>/dev/null; then
        echo "Not Installed"
        exit 0
    fi
    SERVICE_NAME="chronyd"
else
    # Fallback if no known package manager is found
    if ! command -v chronyd &>/dev/null; then
        echo "Not Installed"
        exit 0
    fi
    # If binary exists, try to guess service name
    if systemctl list-units --type=service --all | grep -q 'chrony.service'; then
        SERVICE_NAME="chrony"
    elif systemctl list-units --type=service --all | grep -q 'chronyd.service'; then
        SERVICE_NAME="chronyd"
    else
        # If binary is present but no service file, consider it disabled.
        echo "Disabled"
        exit 0
    fi
fi

# Check if the service is both enabled and active
if systemctl is-enabled "$SERVICE_NAME" &>/dev/null && systemctl is-active "$SERVICE_NAME" &>/dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi