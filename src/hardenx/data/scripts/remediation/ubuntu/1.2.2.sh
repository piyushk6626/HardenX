#!/usr/bin/env bash

# Fail with a standard message and exit code
fail() {
    echo "false"
    exit 1
}

# Succeed with a standard message and exit code
succeed() {
    echo "true"
    exit 0
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   fail
fi

# Check for correct positional argument
if [[ "$1" != "set" ]]; then
    fail
fi

FSTAB_FILE="/etc/fstab"

# Check if /tmp is configured in fstab and is not commented out
if ! grep -qE '^[[:space:]]*[^#].*[[:space:]]+/tmp[[:space:]]+' "$FSTAB_FILE"; then
    # If /tmp is not in fstab, there's nothing to do. This is considered a success.
    succeed
fi

# Check if the nodev option is already present for the /tmp mount
if awk '$1 !~ /^#/ && $2 == "/tmp" && $4 ~ /(^|,)nodev(,|s|$)/ {exit 0} ENDFILE{exit 1}' "$FSTAB_FILE"; then
    # If nodev is already present, the state is correct. This is a success.
    succeed
fi

# If we've reached here, we need to add the nodev option.
# We create a backup and modify the file in one step.
# This sed command finds the line for /tmp, and appends ',nodev' to the options field (field 4).
if ! sed -i.bak -E "s@(^[[:space:]]*[^#].*[[:space:]]+/tmp[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+)@\1,nodev@" "$FSTAB_FILE"; then
    fail
fi

# Remount /tmp to apply the changes immediately.
if ! mount -o remount /tmp; then
    # If remount fails, try to restore from backup and then fail.
    # We don't check for restore failure, as the primary failure is the remount.
    mv -f "${FSTAB_FILE}.bak" "$FSTAB_FILE" &>/dev/null
    fail
fi

succeed
