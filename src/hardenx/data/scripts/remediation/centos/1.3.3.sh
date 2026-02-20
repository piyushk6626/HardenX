#!/usr/bin/env bash

# This script must be run as root
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

# Check for correct number of arguments
if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/dev/shm"

# Check if the mount point exists in fstab and is not commented out
if ! grep -qE "^[^#].*${MOUNT_POINT}" "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

enable_nosuid() {
    # Check if nosuid is already present
    if grep -qE "^[^#].*${MOUNT_POINT}.*\bnosuid\b" "$FSTAB_FILE"; then
        # Already enabled, just ensure it's mounted correctly
        if mount -o remount,nosuid "$MOUNT_POINT"; then
            echo "true"
        else
            echo "false"
        fi
        return
    fi

    # Add nosuid option
    sed -i.bak -E "s|(${MOUNT_POINT}[^[:space:]]*[[:space:]]+[^[:space:]]+[[:space:]]+)([^[:space:]]+)|\1\2,nosuid|" "$FSTAB_FILE"
    if [[ $? -ne 0 ]]; then
        mv "${FSTAB_FILE}.bak" "$FSTAB_FILE" 2>/dev/null
        echo "false"
        return 1
    fi

    # Remount the partition
    if mount -o remount,nosuid "$MOUNT_POINT"; then
        rm -f "${FSTAB_FILE}.bak"
        echo "true"
    else
        # Revert fstab on mount failure
        mv "${FSTAB_FILE}.bak" "$FSTAB_FILE" 2>/dev/null
        echo "false"
    fi
}

disable_nosuid() {
    # Check if nosuid is present to be removed
    if ! grep -qE "^[^#].*${MOUNT_POINT}.*\bnosuid\b" "$FSTAB_FILE"; then
        # Already disabled, ensure it's mounted correctly
        if mount -o remount "$MOUNT_POINT"; then
            echo "true"
        else
            echo "false"
        fi
        return
    fi

    # Remove nosuid option
    sed -i.bak -E "s/(,nosuid|nosuid,)/,/g; s/\bnosuid\b//g; s/,,/,/g" "$FSTAB_FILE"
    if [[ $? -ne 0 ]]; then
        mv "${FSTAB_FILE}.bak" "$FSTAB_FILE" 2>/dev/null
        echo "false"
        return 1
    fi

    # Remount the partition
    if mount -o remount "$MOUNT_POINT"; then
        rm -f "${FSTAB_FILE}.bak"
        echo "true"
    else
        # Revert fstab on mount failure
        mv "${FSTAB_FILE}.bak" "$FSTAB_FILE" 2>/dev/null
        echo "false"
    fi
}

case "$ACTION" in
    enable)
        enable_nosuid
        ;;
    disable)
        disable_nosuid
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac