#!/usr/bin/env bash

# This script must be run with sufficient privileges to modify /etc/fstab and run mount.

if [[ -z "$1" ]]; then
    echo "false"
    exit 1
fi

OPTION_TO_ADD="$1"
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/log"
TEMP_FSTAB=$(mktemp)

# Ensure the temporary file is cleaned up on exit
trap 'rm -f "$TEMP_FSTAB"' EXIT

# Check if the mount point exists in fstab and is not commented out
if ! grep -qE "^\s*[^#]+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

# Use awk to find the line, add the option if it doesn't exist, and print all lines
awk -v opt="$OPTION_TO_ADD" -v mp="$MOUNT_POINT" '
$1 !~ /^#/ && $2 == mp {
    # Check if the option already exists as a whole word, possibly surrounded by commas
    if ($4 !~ "(^|,) *" opt " *(,|$)") {
        if ($4 == "defaults") {
            $4 = "defaults," opt
        } else {
            $4 = $4 "," opt
        }
    }
}
{ print }
' "$FSTAB_FILE" > "$TEMP_FSTAB"

# Atomically replace the old fstab with the new one
if ! mv "$TEMP_FSTAB" "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

# Remount the partition to apply changes
if ! mount -o remount "$MOUNT_POINT"; then
    # Note: If remount fails, the change is still in fstab for the next boot.
    # Reverting the change is outside the scope of this script's requirements.
    echo "false"
    exit 1
fi

echo "true"
exit 0