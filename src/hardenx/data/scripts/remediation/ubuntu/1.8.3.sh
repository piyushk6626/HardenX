#!/bin/bash

if [[ "$1" != "enabled" ]]; then
    echo "false"
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/log/audit"
TMP_FSTAB=$(mktemp)

# Check if /var/log/audit is a dedicated mount point in /etc/fstab
if ! awk -v mp="$MOUNT_POINT" '$2 == mp && !/^[[:space:]]*#/ {found=1; exit} END{exit !found}' "$FSTAB_FILE"; then
    rm -f "$TMP_FSTAB"
    echo "false"
    exit 1
fi

# Check if the option is already present
if ! awk -v mp="$MOUNT_POINT" '$2 == mp' "$FSTAB_FILE" | grep -q '\bnosuid\b'; then
    # Option not found, add it using awk for safety
    awk -v mp="$MOUNT_POINT" '
    $2 == mp && !/^[[:space:]]*#/ {
        $4 = $4 ",nosuid"
    }
    {
        OFS="\t";
        if (NF > 1) {
             # Reconstruct line with tabs to preserve formatting as much as possible
             printf "%s", $1;
             for (i=2; i<=NF; i++) {
                 printf "%s%s", OFS, $i;
             }
             printf "\n";
        } else {
            print $0;
        }
    }
    ' "$FSTAB_FILE" > "$TMP_FSTAB"

    if [[ $? -ne 0 ]]; then
        rm -f "$TMP_FSTAB"
        echo "false"
        exit 1
    fi

    # Overwrite the original fstab
    cat "$TMP_FSTAB" > "$FSTAB_FILE"
    rm -f "$TMP_FSTAB"
fi

# Remount the partition to apply the settings
if ! mount -o remount "$MOUNT_POINT" &>/dev/null; then
    echo "false"
    exit 1
fi

echo "true"
exit 0