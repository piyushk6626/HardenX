#!/bin/bash

DESIRED_STATE="present"
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/dev/shm"
OPTION="nodev"

# 1. Validate input
if [[ $# -ne 1 ]] || [[ "$1" != "$DESIRED_STATE" ]]; then
    echo "false"
    exit 1
fi

# 2. Check if the mount point is defined in fstab. Exit if not.
if ! grep -qE "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

# 3. Check if the option is already present. If so, we just need to remount.
# awk exits 0 if found, 1 if not.
if ! awk -v mp="$MOUNT_POINT" -v opt="$OPTION" '$2 == mp && $4 ~ "(^|,) *"opt"(,|$)" { found=1; exit } END { exit !found }' "$FSTAB_FILE"; then
    # Option is not present, so we need to add it.
    temp_fstab=$(mktemp)
    if [[ ! -f "$temp_fstab" ]]; then
        echo "false"
        exit 1
    fi

    # Use awk to find the line for the mount point and append the option to the 4th field.
    awk -v mp="$MOUNT_POINT" -v opt="$OPTION" '
        $2 == mp { $4 = $4 "," opt }
        { print }
    ' "$FSTAB_FILE" > "$temp_fstab"

    # Check if awk succeeded
    if [[ $? -ne 0 ]]; then
        rm -f "$temp_fstab"
        echo "false"
        exit 1
    fi
    
    # Overwrite the original fstab file with the modified content.
    # This requires root privileges.
    cat "$temp_fstab" > "$FSTAB_FILE"
    exit_code=$?
    rm -f "$temp_fstab"

    if [[ $exit_code -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

# 4. Attempt to remount the filesystem with the new options.
if mount -o remount "$MOUNT_POINT" &>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi