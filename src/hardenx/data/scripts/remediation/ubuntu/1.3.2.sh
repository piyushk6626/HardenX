#!/bin/bash

# Function to be called on failure
fail() {
    echo "false"
    exit 1
}

# Check for the correct positional argument
if [[ $# -ne 1 ]] || [[ "$1" != "enabled" ]]; then
    fail
fi

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/dev/shm"
TEMP_FSTAB="/tmp/fstab.mod.$$"

# Ensure script is run with sufficient privileges
if [[ $EUID -ne 0 ]]; then
   fail
fi

# Ensure fstab exists and is a regular file
if [[ ! -f "$FSTAB_FILE" ]]; then
    fail
fi

# Find the relevant line in fstab, excluding commented lines
fstab_line=$(grep -E "^\s*[^#]+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE")
if [[ -z "$fstab_line" ]]; then
    # Entry for /dev/shm not found
    fail
fi

# Check if the nodev option is already present in the options field (field 4)
# Use a regex that handles it being the only option, or one of many.
if echo "$fstab_line" | awk '{print $4}' | grep -E -q '(^|,)nodev(,|$)'; then
    # Option is already present. We just need to ensure the remount is successful.
    :
else
    # Option is not present, modify fstab
    # We use awk for robust column-based modification
    awk -v mp="$MOUNT_POINT" '
    function is_target(line) {
        # Match lines that are not comments and where field 2 is the mount point
        if (line ~ /^\s*#/ || NF < 4) { return 0 }
        return ($2 == mp)
    }

    is_target($0) {
        # Check if nodev is already in the options (field 4)
        if ($4 !~ /(^|,)nodev(,|)/) {
            $4 = $4 ",nodev"
        }
    }
    { print }' "$FSTAB_FILE" > "$TEMP_FSTAB"

    # Verify awk succeeded and created a non-empty file
    if [[ $? -ne 0 ]] || [[ ! -s "$TEMP_FSTAB" ]]; then
        rm -f "$TEMP_FSTAB"
        fail
    fi

    # Create a backup and replace the original fstab file
    cp "$FSTAB_FILE" "${FSTAB_FILE}.bak.$(date +%s)" || { rm -f "$TEMP_FSTAB"; fail; }
    cat "$TEMP_FSTAB" > "$FSTAB_FILE" || { rm -f "$TEMP_FSTAB"; fail; }
    rm -f "$TEMP_FSTAB"
fi

# Remount the partition to apply the settings immediately
if ! mount -o remount "$MOUNT_POINT"; then
    fail
fi

echo "true"
exit 0