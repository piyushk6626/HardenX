#!/bin/bash

if [[ "$#" -ne 1 ]] || [[ "$1" != "enabled" ]]; then
    false
fi

if [[ "$(id -u)" -ne 0 ]]; then
    false
fi

FSTAB_PATH="/etc/fstab"

if ! grep -qE '^[[:blank:]]*[^#].*[[:blank:]]+/home[[:blank:]]+' "$FSTAB_PATH"; then
    false
fi

home_line_info=$(grep -E '^[[:blank:]]*[^#].*[[:blank:]]+/home[[:blank:]]+' "$FSTAB_PATH")

if echo "$home_line_info" | grep -q '\bnosuid\b'; then
    if mount -o remount /home; then
        true
    else
        false
    fi
    exit $?
fi

if sed -i.bak -E "/^[[:blank:]]*[^#]/{s~([[:blank:]]+/home[[:blank:]]+[^[:blank:]]+[[:blank:]]+)([^[:blank:]]+)~\1\2,nosuid~}" "$FSTAB_PATH"; then
    if mount -o remount /home; then
        true
    else
        mv "${FSTAB_PATH}.bak" "$FSTAB_PATH"
        false
    fi
else
    false
fi