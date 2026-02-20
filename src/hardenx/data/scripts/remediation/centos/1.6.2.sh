#!/usr/bin/env bash

set -euo pipefail

fail() {
    echo "false"
    exit 1
}

if [[ $# -ne 1 ]] || [[ "$1" != "Enabled" && "$1" != "Disabled" ]]; then
    fail
fi

ACTION="$1"
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/tmp"
FSTAB_BACKUP="${FSTAB_FILE}.bak.$(date +%s)"

# Ensure we are running as root
if [[ "$(id -u)" -ne 0 ]]; then
    fail
fi

# Check if the mount point exists in fstab and is not commented out
if ! grep -qE "^\s*[^#]\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    fail
fi

CURRENT_OPTIONS=$(awk -v mp="$MOUNT_POINT" '$2 == mp && !/^[[:space:]]*#/ {print $4}' "$FSTAB_FILE")

if [[ "$ACTION" == "Enabled" ]]; then
    # If already set, it's a success
    if echo ",$CURRENT_OPTIONS," | grep -q ",nodev,"; then
        echo "true"
        exit 0
    fi

    if [[ -z "$CURRENT_OPTIONS" || "$CURRENT_OPTIONS" == "defaults" ]]; then
        NEW_OPTIONS="defaults,nodev"
    else
        NEW_OPTIONS="$CURRENT_OPTIONS,nodev"
    fi

elif [[ "$ACTION" == "Disabled" ]]; then
    # If not set, it's a success
    if ! echo ",$CURRENT_OPTIONS," | grep -q ",nodev,"; then
        echo "true"
        exit 0
    fi

    NEW_OPTIONS=$(echo "$CURRENT_OPTIONS" | sed -e 's/,nodev//g' -e 's/nodev,//g' -e 's/^nodev$//g')
    if [[ -z "$NEW_OPTIONS" ]]; then
        NEW_OPTIONS="defaults"
    fi
fi

# Create a backup before modifying
cp "$FSTAB_FILE" "$FSTAB_BACKUP" || fail

# Use awk to replace the options field safely
awk -v mp="$MOUNT_POINT" -v opts="$NEW_OPTIONS" '
    $2 == mp && !/^[[:space:]]*#/ { $4 = opts }
    { print }
' "$FSTAB_BACKUP" > "$FSTAB_FILE" || { mv "$FSTAB_BACKUP" "$FSTAB_FILE"; fail; }

# Remount to apply the changes
if ! mount -o remount "$MOUNT_POINT"; then
    # Revert fstab on remount failure
    mv "$FSTAB_BACKUP" "$FSTAB_FILE"
    fail
fi

rm -f "$FSTAB_BACKUP"
echo "true"
exit 0