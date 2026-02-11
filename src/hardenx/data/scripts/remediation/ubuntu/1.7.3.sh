#!/usr/bin/env bash

set -euo pipefail

# Script configuration
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/log"
OPTION_TO_ADD="nosuid"
ARGUMENT="$1"

# Function to report failure and exit
fail() {
    echo "false"
    exit 1
}

# --- Main script logic ---

# 1. Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   fail
fi

# 2. Check for the correct positional argument
if [[ "${ARGUMENT}" != "present" ]]; then
    fail
fi

# 3. Verify the mount point exists in /etc/fstab (and is not commented out)
if ! grep -qE "^\s*[^#].*\s+${MOUNT_POINT}\s+" "${FSTAB_FILE}"; then
    fail
fi

# 4. Check if the option is already present for the mount point
# We consider success if it's already there, and just ensure remount works.
current_options=$(awk -v mp="${MOUNT_POINT}" '$2 == mp {print $4}' "${FSTAB_FILE}")
if ! [[ "${current_options}" =~ (^|,)(${OPTION_TO_ADD})(,|$) ]]; then
    # Option is NOT present, so we must add it.
    
    # Create a backup of fstab before modifying
    cp "${FSTAB_FILE}" "${FSTAB_FILE}.bak.$(date +%s)" || fail

    # Use awk to safely add the option to the correct line and field
    awk -v mp="${MOUNT_POINT}" -v opt="${OPTION_TO_ADD}" '
    $2 == mp && !/^\s*#/ {
        if ($4 == "defaults") {
            $4 = "defaults," opt
        } else {
            $4 = $4 "," opt
        }
    }
    { printf "%-25s %-25s %-10s %-30s %-2s %s\n", $1, $2, $3, $4, $5, $6 }
    ' "${FSTAB_FILE}" > "${FSTAB_FILE}.tmp" || fail

    # Verify the temp file is not empty before overwriting
    if [[ ! -s "${FSTAB_FILE}.tmp" ]]; then
        rm -f "${FSTAB_FILE}.tmp"
        fail
    fi

    # Overwrite the original fstab with the modified version
    mv "${FSTAB_FILE}.tmp" "${FSTAB_FILE}" || fail
fi

# 5. Remount the partition to apply the settings
if mount -o remount "${MOUNT_POINT}"; then
    echo "true"
else
    fail
fi