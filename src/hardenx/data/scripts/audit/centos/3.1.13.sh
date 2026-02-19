#!/bin/bash

# Check for package installation status based on the system's package manager
if command -v dpkg &> /dev/null; then
    # For Debian/Ubuntu based systems
    if ! dpkg -s rsync &> /dev/null; then
        echo "Not Installed"
        exit 0
    fi
elif command -v rpm &> /dev/null; then
    # For RHEL/CentOS/Fedora based systems
    if ! rpm -q rsync &> /dev/null; then
        echo "Not Installed"
        exit 0
    fi
elif command -v pacman &> /dev/null; then
    # For Arch based systems
    if ! pacman -Q rsync &> /dev/null; then
        echo "Not Installed"
        exit 0
    fi
else
    # Generic fallback: check if the rsync binary exists.
    # If it doesn't, we can assume the package is not installed.
    if ! command -v rsync &> /dev/null; then
        echo "Not Installed"
        exit 0
    fi
fi

# If we reach this point, the package is considered installed.
# Now, check if the systemd service is enabled.
if systemctl is-enabled rsyncd &> /dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi