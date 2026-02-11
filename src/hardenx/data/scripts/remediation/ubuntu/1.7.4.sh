#!/usr/bin/env bash

set -euo pipefail

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo false
   exit 1
fi

# Check for correct number of arguments and valid values
if [[ $# -ne 1 ]] || [[ "$1" != "Enabled" && "$1" != "Disabled" ]]; then
    echo false
    exit 1
fi

ACTION="$1"
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/log"
TMP_FSTAB=$(mktemp)

# Ensure the temporary file is cleaned up on exit
trap 'rm -f "$TMP_FSTAB"' EXIT

# Verify that /var/log is a distinct entry in fstab before proceeding
if ! grep -qE "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    echo false
    exit 1
fi

# Use awk to process fstab and generate a new version
awk -v action="$ACTION" -v mp="$MOUNT_POINT" '
function join(array, sep,   i, result) {
    for (i = 1; i <= length(array); i++) {
        result = result sep array[i]
        sep = ","
    }
    return result
}

{
    # Preserve original line, only modify if it matches the mount point
    line = $0

    if ($2 == mp) {
        current_opts = $4
        if (action == "Enabled") {
            # Check if noexec is already present. If not, add it.
            if (current_opts !~ /(^|,)noexec(,|$)/) {
                if (current_opts == "defaults") {
                    new_opts = "defaults,noexec"
                } else {
                    new_opts = current_opts ",noexec"
                }
                sub(current_opts, new_opts, line)
            }
        } else { # action == "Disabled"
            # Split options by comma and rebuild the string without noexec
            n = split(current_opts, opts, ",")
            new_opts_arr_len = 0
            delete new_opts_arr
            for (i = 1; i <= n; i++) {
                if (opts[i] != "noexec" && opts[i] != "") {
                    new_opts_arr[++new_opts_arr_len] = opts[i]
                }
            }

            if (new_opts_arr_len > 0) {
                new_opts = join(new_opts_arr, "")
            } else {
                new_opts = "defaults"
            }
            sub(current_opts, new_opts, line)
        }
    }
    print line
}
' "$FSTAB_FILE" > "$TMP_FSTAB"

# Overwrite the original fstab with the modified version.
# This requires root privileges, checked at the start.
if ! cp "$TMP_FSTAB" "$FSTAB_FILE"; then
    echo false
    exit 1
fi

# Remount the partition to apply the changes immediately.
if ! mount -o remount "$MOUNT_POINT"; then
    echo false
    exit 1
fi

echo true
exit 0