#!/usr/bin/env bash

set -euo pipefail

FSTAB="/etc/fstab"
MOUNT_POINT="/var/tmp"
FSTAB_ENTRY_MODIFIED=0

if [[ $# -ne 1 ]]; then
    >&2 echo "Usage: $0 <option>"
    false
    exit 1
fi
readonly DESIRED_OPTION="$1"

if [[ $EUID -ne 0 ]]; then
    >&2 echo "Error: This script must be run as root."
    false
    exit 1
fi

if ! grep -q -E "^\s*[^#]+\s+${MOUNT_POINT}\s+" "$FSTAB"; then
    >&2 echo "Error: Mount point '${MOUNT_POINT}' not found in ${FSTAB}."
    false
    exit 1
fi

if ! awk -v mp="$MOUNT_POINT" -v opt="$DESIRED_OPTION" \
    '$1 !~ /^#/ && $2 == mp && $4 ~ "(^|,)(" opt ")($|,)" { exit 0 } END { exit 1 }' "$FSTAB"; then
    
    TEMP_FSTAB=$(mktemp)
    # shellcheck disable=SC2064
    trap "rm -f '$TEMP_FSTAB'" EXIT

    awk -v mp="$MOUNT_POINT" -v opt="$DESIRED_OPTION" '
    {
        if ($1 !~ /^#/ && $2 == mp) {
            $4 = $4 "," opt
        }
        print
    }' "$FSTAB" > "$TEMP_FSTAB"

    if ! install -b --suffix=.bak."$(date +%s)" -m 644 "$TEMP_FSTAB" "$FSTAB"; then
        >&2 echo "Error: Failed to write changes to ${FSTAB}."
        false
        exit 1
    fi
    FSTAB_ENTRY_MODIFIED=1
fi

if ! mount -o remount "$MOUNT_POINT"; then
    >&2 echo "Error: 'mount -o remount ${MOUNT_POINT}' failed."
    if [[ "$FSTAB_ENTRY_MODIFIED" -eq 1 ]]; then
        >&2 echo "Warning: ${FSTAB} was modified but the remount failed. Manual intervention may be required."
    fi
    false
    exit 1
fi

true
exit 0