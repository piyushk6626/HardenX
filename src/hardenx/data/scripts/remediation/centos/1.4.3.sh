#!/usr/bin/env bash

# Exit on any error
set -e

# Define a failure function
fail() {
    echo "false"
    exit 1
}

# Trap errors to call the fail function
trap fail ERR

# Check if the positional argument is 'Present'
if [[ "$1" != "Present" ]]; then
    fail
fi

# Check for root privileges, as they are required to modify /etc/fstab and remount
if [[ $EUID -ne 0 ]]; then
   fail
fi

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/home"

# Check if the mount point exists in fstab and if 'nosuid' is already present.
# We only proceed if the entry exists and 'nosuid' is missing.
if grep -qE "^[[:space:]]*[^#].*${MOUNT_POINT}[[:space:]]" "${FSTAB_FILE}" && \
   ! grep -qE "^[[:space:]]*[^#].*${MOUNT_POINT}[[:space:]].*nosuid" "${FSTAB_FILE}"; then
    
    # Create a backup before modifying
    cp "${FSTAB_FILE}" "${FSTAB_FILE}.bak.$(date +%s)"
    
    # Use awk to idempotently add the 'nosuid' option to the correct line
    # This is more robust than sed for manipulating columns
    awk -v mount_point="${MOUNT_POINT}" '
    {
        # Check if the line is not a comment and the second field is our mount point
        if ($1 !~ /^#/ && $2 == mount_point) {
            # Append ,nosuid to the fourth field (options)
            $4 = $4",nosuid"
        }
        # Print the (potentially modified) line
        print
    }
    ' "${FSTAB_FILE}" > "${FSTAB_FILE}.tmp"

    # Overwrite the original fstab with the modified temporary file
    mv "${FSTAB_FILE}.tmp" "${FSTAB_FILE}"
fi

# Remount the partition to apply the new settings. This will also verify syntax.
mount -o remount "${MOUNT_POINT}"

# If all commands succeeded, echo true
echo "true"
exit 0