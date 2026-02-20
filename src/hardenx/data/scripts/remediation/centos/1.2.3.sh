#!/usr/bin/env bash

if [[ "$1" != "Enabled" ]]; then
    echo "false"
    exit 1
fi

FSTAB_FILE="/etc/fstab"

if ! grep -qE '^\S+\s+/tmp\s+' "$FSTAB_FILE"; then
    echo "false"
    exit 1
fi

if ! grep -E '^\S+\s+/tmp\s+' "$FSTAB_FILE" | awk '{print $4}' | grep -q 'nosuid'; then
    sed -i.bak -E '/^\S+\s+\/tmp\s+/ s/\S+/&,nosuid/4' "$FSTAB_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

if mount -o remount /tmp; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi