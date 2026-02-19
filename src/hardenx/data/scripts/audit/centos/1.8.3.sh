#!/usr/bin/env bash

# Find the device for /var/log/audit and the root directory
# df --output=source prints the source device. tail -n 1 removes the header.
audit_device=$(df --output=source /var/log/audit 2>/dev/null | tail -n 1)
root_device=$(df --output=source / 2>/dev/null | tail -n 1)

# If df failed (e.g., directory doesn't exist), we can't determine the partition.
# Assuming 'not_applicable' is a safe default in this edge case.
if [ -z "$audit_device" ]; then
    # This case also covers when /var/log/audit doesn't exist.
    # We can't determine its partition, so it's not a dedicated one.
    echo "not_applicable"
    exit 0
fi

# Compare the devices to see if /var/log/audit is on its own partition
if [ "$audit_device" == "$root_device" ]; then
    echo "not_applicable"
else
    # It's a dedicated partition, so check its mount options for 'nosuid'
    # findmnt is a modern tool to inspect filesystems. -n for no header, -o for specific column.
    # grep -q is quiet and returns a status code. -w matches the whole word.
    if findmnt -n -o OPTIONS --target /var/log/audit | grep -qw 'nosuid'; then
        echo "enabled"
    else
        echo "disabled"
    fi
fi