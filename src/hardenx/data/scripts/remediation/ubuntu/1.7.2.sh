#!/usr/bin/env bash

if [[ $EUID -ne 0 ]] || [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/log"
TMP_FSTAB=$(mktemp)

# Ensure temp file is cleaned up on exit
trap 'rm -f "$TMP_FSTAB"' EXIT

# Check if mount point exists in fstab
if ! grep -q -E "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

case "$ACTION" in
    Enabled)
        # Add 'nodev' if it's not already present in the options for the mount point
        awk -v mp="$MOUNT_POINT" '
            $2 == mp {
                if ($4 !~ /(^|,)nodev($|,)/) {
                    $4 = $4 ",nodev"
                }
            }
            { print }
        ' OFS='\t' "$FSTAB_FILE" > "$TMP_FSTAB"
        ;;
    Disabled)
        # Remove 'nodev' if it is present
        awk -v mp="$MOUNT_POINT" '
            $2 == mp {
                sub(/,nodev/, "", $4);
                sub(/nodev,/, "", $4);
                sub(/^nodev$/, "defaults", $4);
            }
            { print }
        ' OFS='\t' "$FSTAB_FILE" > "$TMP_FSTAB"
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac

# Check if awk failed
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Atomically replace the original fstab and remount
if cp "$TMP_FSTAB" "$FSTAB_FILE" && mount -o remount "$MOUNT_POINT"; then
    echo "true"
else
    echo "false"
fi