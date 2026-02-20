#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

FSTAB_FILE="/etc/fstab"
TMP_MOUNT="/tmp"
FSTAB_TEMP_FILE=$(mktemp)

# Ensure /tmp has a dedicated entry in fstab
if ! grep -q -E "^\S+\s+${TMP_MOUNT}\s+" "$FSTAB_FILE"; then
    rm -f "$FSTAB_TEMP_FILE"
    echo "false"
    exit 1
fi

# Check if fstab already has the nodev option for /tmp
# We grep for the mount point, then awk to check the 4th column for nodev
if ! awk -v mount_point="$TMP_MOUNT" '$2 == mount_point && $4 ~ /(^|,)nodev(,|$)/ { exit 0 } END { exit 1 }' "$FSTAB_FILE"; then
    # fstab needs to be modified
    awk -v mp="$TMP_MOUNT" '
        $2 == mp { $4 = $4 ",nodev" }
        { print }
    ' "$FSTAB_FILE" > "$FSTAB_TEMP_FILE"

    if [[ $? -eq 0 && -s "$FSTAB_TEMP_FILE" ]]; then
        # Overwrite the original fstab file
        cat "$FSTAB_TEMP_FILE" > "$FSTAB_FILE"
        if [[ $? -ne 0 ]]; then
            rm -f "$FSTAB_TEMP_FILE"
            echo "false"
            exit 1
        fi
    else
        rm -f "$FSTAB_TEMP_FILE"
        echo "false"
        exit 1
    fi
fi

rm -f "$FSTAB_TEMP_FILE"

# Now, ensure the partition is mounted with nodev
if ! mount | grep -q -E "\s+on\s+${TMP_MOUNT}\s+.*(\(|,)nodev(,|,)"; then
    # If not, remount it
    if ! mount -o remount,nodev "$TMP_MOUNT"; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0
