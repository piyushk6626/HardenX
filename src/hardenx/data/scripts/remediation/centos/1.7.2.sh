#!/usr/bin/env bash

MOUNT_POINT="/var/log"
FSTAB_FILE="/etc/fstab"
OPTION_TO_ADD="nodev"

# Check if the mount point exists as a distinct partition in /etc/fstab
# awk: non-commented line ($1 !~ /^#/) where the 2nd field is an exact match
if ! grep -E -q "^\s*[^#]\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    echo "false"
    exit 0
fi

# Get the current options for the mount point
current_options=$(awk -v mp="$MOUNT_POINT" '$2 == mp {print $4}' "$FSTAB_FILE")

# Check if the option is already present
if ! [[ ",${current_options}," == *",${OPTION_TO_ADD},"* ]]; then
    # The option is not present, so add it
    # Using a non-greedy match for the first two fields to handle UUIDs/labels with spaces
    # Using '|' as the sed delimiter to avoid escaping the path slashes
    if ! sed -i.bak "s|^\(\S\+\s\+${MOUNT_POINT}\s\+\S\+\s\+\)\(\S\+\)\(.*\)|\1\2,${OPTION_TO_ADD}\3|" "$FSTAB_FILE"; then
        echo "false"
        exit 0
    fi
fi

# Apply the changes by remounting the partition
if mount -o remount "${MOUNT_POINT}" &>/dev/null; then
    echo "true"
else
    echo "false"
fi