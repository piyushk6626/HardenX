#!/usr/bin/env bash

# This script must be run with sufficient privileges (e.g., as root or with sudo)
# to modify /etc/pam.d/common-password.

set -e
set -o pipefail

TARGET_FILE="/etc/pam.d/common-password"
TARGET_LINE="password requisite pam_pwquality.so retry=3"
ACTION="$1"

# --- Argument and File Validation ---
if [[ "$#" -ne 1 ]] || { [[ "$ACTION" != "enabled" ]] && [[ "$ACTION" != "disabled" ]]; }; then
    false
fi

if [[ ! -f "$TARGET_FILE" ]] || [[ ! -w "$TARGET_FILE" ]]; then
    false
fi

# --- Main Logic ---
case "$ACTION" in
    enabled)
        # Case 1: The line already exists and is uncommented. Success.
        if grep -qFx "$TARGET_LINE" "$TARGET_FILE"; then
            true
        # Case 2: The line exists but is commented out. Uncomment it.
        elif grep -qFx "#${TARGET_LINE}" "$TARGET_FILE"; then
            # Using a non-standard delimiter like '|' to avoid issues if TARGET_LINE contained '/'
            sed -i "s|^#${TARGET_LINE}|${TARGET_LINE}|" "$TARGET_FILE"
        # Case 3: The line does not exist in any form. Add it.
        else
            echo "$TARGET_LINE" >> "$TARGET_FILE"
        fi
        ;;
    disabled)
        # Case 1: The line exists and is uncommented. Comment it out.
        if grep -qFx "$TARGET_LINE" "$TARGET_FILE"; then
            sed -i "s|^${TARGET_LINE}|#${TARGET_LINE}|" "$TARGET_FILE"
        # Case 2: The line is already commented or does not exist. This is a success state for 'disabled'.
        else
            true
        fi
        ;;
esac