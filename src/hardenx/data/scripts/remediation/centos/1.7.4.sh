#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]] || [[ "$1" != "enabled" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

MOUNT_POINT="/var/log"
FSTAB_FILE="/etc/fstab"
TMP_FSTAB=$(mktemp)

trap 'rm -f "$TMP_FSTAB"' EXIT

# Verify /var/log is a separate partition
if ! findmnt --noheadings --target "$MOUNT_POINT" &>/dev/null; then
    echo "false"
    exit 1
fi

# Verify there is an entry for /var/log in fstab
if ! grep -q -E "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

# Use awk to idempotently add the 'noexec' option
awk -v mp="$MOUNT_POINT" '
$2 == mp {
    # Check if noexec is already present as a whole word option
    if ($4 !~ /(^|,)noexec(,$|)/) {
        if ($4 == "defaults") {
            $4 = "defaults,noexec"
        } else {
            $4 = $4 ",noexec"
        }
    }
}
{ print }' "$FSTAB_FILE" > "$TMP_FSTAB"

# Check for awk failure
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Atomically replace the fstab file if changes were made
if ! cmp -s "$FSTAB_FILE" "$TMP_FSTAB"; then
    cat "$TMP_FSTAB" > "$FSTAB_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

# Remount the partition to apply the changes
if mount -o remount "$MOUNT_POINT" &>/dev/null; then
    echo "true"
else
    echo "false"
    exit 1
fi