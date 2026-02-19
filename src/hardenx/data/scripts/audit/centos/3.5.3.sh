#!/bin/bash

# Check for chrony installation across RPM and DPKG based systems.
if ! (rpm -q chrony &>/dev/null || dpkg -s chrony &>/dev/null); then
    echo "Not Installed"
    exit 0
fi

enabled_status=$(systemctl is-enabled chronyd 2>/dev/null)
active_status=$(systemctl is-active chronyd 2>/dev/null)

# Handle potential 'static' enabled state by treating it as 'Enabled'
if [[ "$enabled_status" == "static" ]]; then
    enabled_status="enabled"
fi

# Capitalize the first letter of each status string
enabled_status_cap="${enabled_status^}"
active_status_cap="${active_status^}"

echo "$enabled_status_cap and $active_status_cap"