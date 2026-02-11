#!/bin/bash

set -e

cleanup() {
    if [[ -n "$TEMP_FSTAB" && -f "$TEMP_FSTAB" ]]; then
        rm -f "$TEMP_FSTAB"
    fi
}

fail() {
    echo "false"
    exit 1
}

trap cleanup EXIT
trap fail ERR

if [[ "$EUID" -ne 0 || "$#" -ne 1 || "$1" != "enabled" ]]; then
    fail
fi

FSTAB="/etc/fstab"
MOUNT_POINT="/dev/shm"
TEMP_FSTAB=$(mktemp)

if ! grep -q "^\s*[^#].*\s${MOUNT_POINT}\s" "$FSTAB"; then
    fail
fi

awk -v mp="$MOUNT_POINT" '
    $2 == mp && $1 !~ /^#/ && $4 !~ /(^|,)noexec($|,)/ {
        $4 = $4",noexec"
    }
    { print }
' "$FSTAB" > "$TEMP_FSTAB"

if ! cmp -s "$FSTAB" "$TEMP_FSTAB"; then
    cat "$TEMP_FSTAB" > "$FSTAB"
fi

mount -o remount,noexec "$MOUNT_POINT"

echo "true"
exit 0