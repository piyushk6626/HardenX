#!/bin/bash

set -e
set -o pipefail

if [[ "$1" != "enabled" ]]; then
    echo "false"
    exit 1
fi

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/tmp"
OPTION="nosuid"
TEMP_FSTAB=$(mktemp)

# Ensure the temp file is removed on exit
trap 'rm -f "$TEMP_FSTAB"' EXIT

# Check if an uncommented entry for the mount point exists
if ! grep -qE "^[[:space:]]*[^#].*[[:space:]]+${MOUNT_POINT}([[:space:]]|$)" "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

# Check if the option is already present for the specific mount point
if grep -E "^[[:space:]]*[^#].*[[:space:]]+${MOUNT_POINT}([[:space:]]|$)" "$FSTAB_FILE" | grep -q "\b${OPTION}\b"; then
    # Option already exists, just try to remount and report status
    if mount -o remount "$MOUNT_POINT"; then
        echo "true"
    else
        echo "false"
    fi
    exit 0
fi

# Use awk to robustly add the option to the correct line and field
awk -v mp="$MOUNT_POINT" -v opt="$OPTION" '
{
    # Check if the line is for the target mount point and not commented out
    if ($2 == mp && $1 !~ /^#/) {
        # Split options by comma to check for an empty/default field
        n = split($4, a, ",")
        if (n == 1 && (a[1] == "defaults" || a[1] == "" || a[1] == "0")) {
             $4 = "defaults," opt
        } else {
             $4 = $4 "," opt
        }
    }
    # Print the (potentially modified) line, preserving original spacing as much as possible
    printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $5, $6
}' "$FSTAB_FILE" > "$TEMP_FSTAB"

# Atomically replace the original fstab if awk succeeded
if [ -s "$TEMP_FSTAB" ]; then
    cat "$TEMP_FSTAB" > "$FSTAB_FILE"
else
    echo "false"
    exit 1
fi

# Remount to apply changes and report final status
if mount -o remount "$MOUNT_POINT"; then
    echo "true"
else
    echo "false"
fi