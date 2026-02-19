#!/usr/bin/env bash

# Check if the rsyslog service unit exists at all.
# systemctl will return a non-zero exit code if the unit is not found.
systemctl cat rsyslog.service &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "Not Installed"
    exit 0
fi

# If the unit exists, check if it's enabled.
# systemctl is-enabled has a zero exit code only if the status is "enabled".
if systemctl is-enabled --quiet rsyslog.service; then
    echo "enabled"
else
    echo "disabled"
fi