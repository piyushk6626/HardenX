#!/bin/bash

set -e
set -o pipefail

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/var/log/audit"
OPTION="noexec"
ACTION="$1"



# --- Check for fstab entry ---
if ! grep -q -E "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

# --- Get current options from fstab ---
current_opts=$(awk -v mp="$MOUNT_POINT" '$2 == mp {print $4}' "$FSTAB_FILE")
has_option=false
if [[ "$current_opts" =~ (^|,)noexec(,|$) ]]; then
    has_option=true
fi

# --- Main Logic ---
if [[ "$ACTION" == "Enabled" ]]; then
    if "$has_option"; then
        echo "true"
        exit 0
    fi

    # Add the noexec option
    temp_fstab=$(mktemp)
    awk -v mp="$MOUNT_POINT" -v opt="$OPTION" '
    $2 == mp {
        $4 = $4 "," opt
    }
    1' "$FSTAB_FILE" > "$temp_fstab"

    if ! cp "$temp_fstab" "$FSTAB_FILE"; then
        rm -f "$temp_fstab"
        echo "false"
        exit 1
    fi
    rm -f "$temp_fstab"

    # Remount the partition
    if ! mount -o remount,"${OPTION}" "${MOUNT_POINT}"; then
        echo "false"
        exit 1
    fi

elif [[ "$ACTION" == "Disabled" ]]; then
    if ! "$has_option"; then
        echo "true"
        exit 0
    fi

    # Remove the noexec option
    temp_fstab=$(mktemp)
    awk -v mp="$MOUNT_POINT" -v opt="$OPTION" '
    $2 == mp {
        sub(",?" opt ",?", ",", $4);
        sub(/^,|,$/, "", $4);
        if ($4 == "") $4 = "defaults";
    }
    1' "$FSTAB_FILE" > "$temp_fstab"

    if ! cp "$temp_fstab" "$FSTAB_FILE"; then
        rm -f "$temp_fstab"
        echo "false"
        exit 1
    fi
    rm -f "$temp_fstab"

    # Remount to apply new fstab settings
    if ! mount -o remount "${MOUNT_POINT}"; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0
