#!/usr/bin/env bash

# Define constants
FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/log/audit"
TARGET_OPTION="nodev"

# Function to report failure and exit
fail() {
    echo "false"
    exit 1
}

# --- Pre-flight Checks ---

# 1. Check for root privileges
if [[ "$EUID" -ne 0 ]]; then
    fail
fi

# 2. Validate input argument
ACTION="$1"
if [[ "$ACTION" != "Enabled" && "$ACTION" != "Disabled" ]]; then
    fail
fi

# 3. Ensure the mount point exists in /etc/fstab
# Using awk to be precise about matching the second column
if ! awk -v mp="$MOUNT_POINT" '$2 == mp { exit 0 } ENDFILE { exit 1 }' "$FSTAB_FILE"; then
    fail
fi

# --- Main Logic ---

# Use a temporary file for modifications
TMP_FSTAB=$(mktemp)
trap 'rm -f "$TMP_FSTAB"' EXIT

MODIFIED=0

if [[ "$ACTION" == "Enabled" ]]; then
    # Add the 'nodev' option if it doesn't exist for the target mount point
    awk -v mp="$MOUNT_POINT" -v opt="$TARGET_OPTION" '
    function check_opt(options, option_to_check) {
        split(options, arr, ",");
        for (i in arr) {
            if (arr[i] == option_to_check) return 1; # Found
        }
        return 0; # Not found
    }
    $2 == mp {
        if (!check_opt($4, opt)) {
            $4 = $4 "," opt;
            print "MODIFIED" > "/dev/stderr";
        }
    }
    { print }' "$FSTAB_FILE" 2> >(read MOD_FLAG) > "$TMP_FSTAB"
    if [[ "$MOD_FLAG" == "MODIFIED" ]]; then
        MODIFIED=1
    fi

elif [[ "$ACTION" == "Disabled" ]]; then
    # Remove the 'nodev' option if it exists
    awk -v mp="$MOUNT_POINT" -v opt="$TARGET_OPTION" '
    $2 == mp {
        original_opts = $4
        gsub("," opt, "", $4); # case: defaults,nodev
        gsub(opt ",", "", $4); # case: nodev,defaults
        # case: only nodev -> replace with defaults
        if ($4 == opt) $4 = "defaults";
        if (original_opts != $4) {
            print "MODIFIED" > "/dev/stderr";
        }
    }
    { print }' "$FSTAB_FILE" 2> >(read MOD_FLAG) > "$TMP_FSTAB"
     if [[ "$MOD_FLAG" == "MODIFIED" ]]; then
        MODIFIED=1
    fi
fi

# --- Apply Changes and Remount ---

# If we made a change, update /etc/fstab.
if [[ "$MODIFIED" -eq 1 ]]; then
    # Using cat and redirect to preserve permissions, rather than mv
    cat "$TMP_FSTAB" > "$FSTAB_FILE" || fail
fi

# Attempt to remount the filesystem to apply the new options
mount -o remount "$MOUNT_POINT" || fail

# If we reached here, everything was successful
echo "true"
exit 0