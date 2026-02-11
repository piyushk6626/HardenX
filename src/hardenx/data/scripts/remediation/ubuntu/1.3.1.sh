#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ "$1" != "mount" ]]; then
    echo "false"
    exit 1
fi

FSTAB_ENTRY="tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0"
FSTAB_FILE="/etc/fstab"

if ! grep -qFx -- "$FSTAB_ENTRY" "$FSTAB_FILE"; then
    if ! echo "$FSTAB_ENTRY" >> "$FSTAB_FILE"; then
        echo "false"
        exit 1
    fi
fi

# Try to mount. If already mounted, `mount` might fail, so try remounting
# to apply the new fstab options.
if mount /dev/shm &>/dev/null || mount -o remount /dev/shm &>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi