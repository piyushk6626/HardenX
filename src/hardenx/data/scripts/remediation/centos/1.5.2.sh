#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
  echo "false"
  exit 1
fi

if [[ "$1" != "enabled" ]]; then
  echo "false"
  exit 1
fi

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var"
TMP_FSTAB_FILE="${FSTAB_FILE}.tmp"

# Ensure the mount point exists in fstab before proceeding
if ! grep -q -E "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

# Check if 'nodev' option is already present for the mount point
# awk exits with 0 if found, 1 if not found. We only proceed if it's not found (exit code 1).
if awk -v mp="$MOUNT_POINT" '$2 == mp && $4 ~ /(^|,)nodev(,?|$)/ { exit 0 } END { exit 1 }' "$FSTAB_FILE"; then
    NEEDS_MODIFY=false
else
    NEEDS_MODIFY=true
fi

if [[ "$NEEDS_MODIFY" == true ]]; then
    # Use awk to add the 'nodev' option idempotently and safely to a temp file
    awk -v mp="$MOUNT_POINT" '
    BEGIN { OFS=FS="\t" }
    $2 == mp {
        # Re-check to be certain, then append ',nodev' to the options field
        if ($4 !~ /(^|,)nodev(,?|$)/) {
            $4 = $4 ",nodev"
        }
    }
    { print }
    ' "$FSTAB_FILE" > "$TMP_FSTAB_FILE"

    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi

    # Atomically replace the original fstab with the modified one
    if ! mv "$TMP_FSTAB_FILE" "$FSTAB_FILE"; then
        echo "false"
        exit 1
    fi
fi

# Attempt to remount to apply the new settings
if mount -o remount "$MOUNT_POINT"; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi