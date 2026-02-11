#!/usr/bin/env bash

set -eo pipefail

if [[ $EUID -ne 0 ]] || [[ "$1" != "enabled" ]]; then
    echo "false"
    exit 1
fi

FSTAB_FILE="/etc/fstab"
MOUNT_POINT="/dev/shm"

if ! [ -f "$FSTAB_FILE" ] && [ -w "$FSTAB_FILE" ]; then
    echo "false"
    exit 1
fi

FSTAB_TMP=$(mktemp)
trap 'rm -f "$FSTAB_TMP"' EXIT

if grep -q -E "^\S+\s+${MOUNT_POINT}\s+" "$FSTAB_FILE"; then
    awk -v mp="$MOUNT_POINT" '
        $2 == mp {
            if ($4 !~ /(^|,)nosuid($|,)/) {
                if ($4 == "defaults") {
                    $4 = "defaults,nosuid"
                } else {
                    $4 = $4 ",nosuid"
                }
            }
        }
        { print }
    ' "$FSTAB_FILE" > "$FSTAB_TMP"
else
    cp "$FSTAB_FILE" "$FSTAB_TMP"
    echo "tmpfs ${MOUNT_POINT} tmpfs defaults,nosuid 0 0" >> "$FSTAB_TMP"
fi

cat "$FSTAB_TMP" > "$FSTAB_FILE"

mount -o remount "$MOUNT_POINT"

if mount | grep -E " on ${MOUNT_POINT} .*nosuid"; then
    echo "true"
else
    echo "false"
    exit 1
fi