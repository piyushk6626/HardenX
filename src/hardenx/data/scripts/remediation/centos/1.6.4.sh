#!/bin/bash

# Ensure script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Validate input argument
if [[ $# -ne 1 ]] || [[ "$1" != "noexec" && "$1" != "exec" ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"
FSTAB="/etc/fstab"
MOUNT_POINT="/var/tmp"
TEMP_FSTAB=$(mktemp)
trap 'rm -f "$TEMP_FSTAB"' EXIT

# Check if /var/tmp is a separate mount point in fstab
if ! grep -qE "^[^#].*[[:space:]]${MOUNT_POINT}[[:space:]]" "$FSTAB"; then
    echo "false"
    exit 1
fi

# Process fstab with awk to modify the options
awk -v mp="$MOUNT_POINT" -v action="$ACTION" '
{
    # Check if the line is not a comment and matches the mount point
    if ($1 !~ /^#/ && $2 == mp) {
        # Action: add noexec
        if (action == "noexec") {
            # Check if noexec is already present
            if ($4 !~ /(^|,)noexec(,?)/) {
                # Add noexec to the options
                if ($4 == "") {
                    $4 = "noexec"
                } else {
                    $4 = $4 ",noexec"
                }
            }
        }
        # Action: remove noexec
        else if (action == "exec") {
            # This series of subs covers all cases for removing noexec
            sub(/,noexec,/, ",", $4) # In the middle
            sub(/^noexec,/, "", $4)   # At the start
            sub(/,noexec$/, "", $4)   # At the end
            sub(/^noexec$/, "defaults", $4) # As the only option
        }
    }
    # Print the (potentially modified) line with tab separators
    print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6
}' "$FSTAB" > "$TEMP_FSTAB"

# Check if awk succeeded and created the temp file
if [[ $? -ne 0 ]] || [[ ! -s "$TEMP_FSTAB" ]]; then
    echo "false"
    exit 1
fi

# If changes were made, update fstab and remount
if ! cmp -s "$FSTAB" "$TEMP_FSTAB"; then
    # Create a backup before overwriting
    cp "$FSTAB" "${FSTAB}.bak.$(date +%s)"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
    
    cat "$TEMP_FSTAB" > "$FSTAB"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

# Remount the partition to apply changes
if mount -o remount "$MOUNT_POINT"; then
    echo "true"
else
    echo "false"
fi