#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]] || [[ "$1" != "enabled" ]]; then
    echo "false"
    exit 0
fi

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/log/audit"

# Find the relevant, uncommented line for the mount point in /etc/fstab
FSTAB_LINE=$(grep -E "^\s*[^#]" "$FSTAB_FILE" | awk -v mp="$MOUNT_POINT" '$2 == mp {print $0; exit}')

# If no such line exists, it's not a separate partition.
if [[ -z "$FSTAB_LINE" ]]; then
    echo "false"
    exit 0
fi

# Extract the options field (4th column)
OPTIONS=$(echo "$FSTAB_LINE" | awk '{print $4}')

# Check if 'nosuid' is already present. The regex ensures 'nosuid' is a whole word.
if echo "$OPTIONS" | grep -q -E '(^|,)nosuid(,|$)'; then
    # The option is already set. The configuration is correct.
    # A remount ensures the current state matches fstab.
    if mount -o remount "$MOUNT_POINT" &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
    exit 0
fi

# The 'nosuid' option is missing. Add it.
TMP_FSTAB=$(mktemp)
trap 'rm -f "$TMP_FSTAB"' EXIT

# Use awk to find the correct line and append ',nosuid' to the options field.
awk -v mp="$MOUNT_POINT" '
{
    if ($1 !~ /^#/ && $2 == mp) {
        $4 = $4 ",nosuid"
    }
    print
}' "$FSTAB_FILE" > "$TMP_FSTAB"

# Atomically and safely replace the original fstab.
# This requires root privileges, which is implicit for this task.
if ! cp "$TMP_FSTAB" "$FSTAB_FILE"; then
    echo "false"
    exit 0
fi

# Attempt to remount the filesystem to apply the change immediately.
if mount -o remount "$MOUNT_POINT" &>/dev/null; then
    echo "true"
else
    # The fstab was modified, but the remount failed. Overall failure.
    echo "false"
fi