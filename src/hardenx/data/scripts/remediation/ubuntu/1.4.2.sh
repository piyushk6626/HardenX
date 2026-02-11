#!/usr/bin/env bash

if [[ "$1" != "Enabled" ]]; then
    exit 1
fi

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/home"

# Check if a non-commented entry for the mount point exists
if ! grep -qE "^[[:space:]]*[^#]+[[:space:]]+${MOUNT_POINT}[[:space:]]+" "$FSTAB_FILE"; then
    exit 1
fi

# Extract the current options for the mount point
current_options=$(awk -v mp="$MOUNT_POINT" '!/^#/ && $2 == mp {print $4}' "$FSTAB_FILE")

# Idempotency check: if 'nodev' is already present, we only need to remount
if echo "$current_options" | grep -qE '(^|,)nodev(,|$)'; then
    if mount -o remount "$MOUNT_POINT"; then
        exit 0
    else
        exit 1
    fi
fi

# 'nodev' is not present, so add it. Create a backup.
# This sed command finds the correct line and appends ',nodev' to the 4th field.
# It's constructed to handle various whitespace and fstab formats.
if ! sed -i.bak -E "s|^([^#].*[[:space:]]+${MOUNT_POINT}[[:space:]]+[^[:space:]]+[[:space:]]+)([^[:space:]]+)(.*)|\1\2,nodev\3|" "$FSTAB_FILE"; then
    # Restore from backup if sed fails
    [ -f "${FSTAB_FILE}.bak" ] && mv "${FSTAB_FILE}.bak" "$FSTAB_FILE"
    exit 1
fi

# Attempt to remount to apply the new setting
if mount -o remount "$MOUNT_POINT"; then
    # Success, remove backup
    rm -f "${FSTAB_FILE}.bak"
    exit 0
else
    # Remount failed, restore from backup and fail
    mv "${FSTAB_FILE}.bak" "$FSTAB_FILE"
    exit 1
fi