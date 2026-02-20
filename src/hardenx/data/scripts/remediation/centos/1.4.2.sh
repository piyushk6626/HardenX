#!/usr/bin/env bash

# This script must be run as root
if [[ $EUID -ne 0 ]]; then
   exit 1
fi

if [[ "$1" != "set" ]]; then
    exit 1
fi

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/home"
TMP_FSTAB="/tmp/fstab.$$"

# Check if /home is a separate partition in fstab
if ! grep -q -E "^\s*[^#]+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    # Do nothing as requested if /home is not a separate partition
    exit 0
fi

# Use awk to safely modify the fstab entry
# It finds the /home line, and if 'nodev' isn't already an option, adds it.
awk -v mp="$MOUNT_POINT" '
    $2 == mp && !/^\s*#/ {
        if ($4 !~ /(^|,)nodev(,|s*$)/) {
            if ($4 == "" || $4 == "defaults") {
                $4 = $4 ",nodev"
                # Clean up leading comma if defaults was empty
                sub(/^,/, "", $4)
            } else {
                $4 = $4 ",nodev"
            }
        }
    }
    {
        # Rebuild the line with tabs to preserve spacing as much as possible
        printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $5, $6
        # Handle any fields beyond the 6th
        for (i=7; i<=NF; i++) printf "\t%s", $i
        if (NF > 6) printf "\n"
    }
' "$FSTAB_FILE" > "$TMP_FSTAB"

if [[ $? -ne 0 ]]; then
    rm -f "$TMP_FSTAB"
    exit 1
fi

# Create a backup and replace the original file
cp "$FSTAB_FILE" "${FSTAB_FILE}.bak.$(date +%s)" || { rm -f "$TMP_FSTAB"; exit 1; }
cat "$TMP_FSTAB" > "$FSTAB_FILE" || { rm -f "$TMP_FSTAB"; exit 1; }
rm -f "$TMP_FSTAB"

# Remount /home to apply the new settings
if mount -o remount "$MOUNT_POINT"; then
    exit 0
else
    # An error occurred, maybe revert the file? For now, just fail.
    exit 1
fi