#!/usr/bin/env bash

# --- Configuration ---
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/tmp"
ACTION="$1"

# --- Validation ---
if [[ $# -ne 1 ]] || [[ "$ACTION" != "enabled" && "$ACTION" != "disabled" ]]; then
    echo "false"
    exit 1
fi

if ! [ -f "$FSTAB_FILE" ] || ! [ -w "$FSTAB_FILE" ]; then
    echo "false"
    exit 1
fi

# Check if the mount point exists in fstab
# The awk script below will handle this, but an early exit is cleaner.
if ! awk -v mp="$MOUNT_POINT" '$2 == mp { exit 0 } ENDFILE { exit 1 }' "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi


# --- Main Logic ---
TEMP_FSTAB=$(mktemp)
if [ -z "$TEMP_FSTAB" ]; then
    echo "false"
    exit 1
fi
trap 'rm -f "$TEMP_FSTAB"' EXIT

# Use awk to safely edit the correct line and column
awk -v action="$ACTION" -v mp="$MOUNT_POINT" '
{
    # Operate only on the target mount point line
    if ($2 == mp) {
        # Check if nodev is already present
        has_nodev = ($4 ~ /(^|,)nodev(,|)/)

        if (action == "enabled" && !has_nodev) {
            # Add nodev if not present
            if ($4 ~ /^[[:space:]]*$/ || $4 == "defaults") {
                $4 = "defaults,nodev"
            } else {
                $4 = $4 ",nodev"
            }
        } else if (action == "disabled" && has_nodev) {
            # Remove nodev if present
            # Strategy: remove "nodev," ",nodev", and if only "nodev" exists, replace with "defaults"
            sub(/^nodev,/, "", $4);
            sub(/,nodev/, "", $4);
            sub(/^nodev$/, "defaults", $4);
            # If after removal the options are empty, set to defaults
            if ($4 ~ /^[[:space:]]*$/) {
                $4 = "defaults"
            }
        }
    }
    # Print the line (original or modified)
    print $0;
}
' "$FSTAB_FILE" > "$TEMP_FSTAB"

# Check if awk failed or produced an empty file
if [[ $? -ne 0 ]] || ! [ -s "$TEMP_FSTAB" ]; then
    echo "false"
    exit 1
fi

# Overwrite the original fstab with the modified temp file
# Using cat and redirection to preserve original permissions as much as possible
if ! (cat "$TEMP_FSTAB" > "$FSTAB_FILE"); then
    echo "false"
    exit 1
fi

# --- Remount ---
if mount -o remount "$MOUNT_POINT" &>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi