#!/bin/bash

if [[ $# -ne 1 || $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

TARGET_FILE="/etc/login.defs"
NEW_UMASK="$1"

if [[ ! -f "$TARGET_FILE" || ! -w "$TARGET_FILE" ]]; then
    echo "false"
    exit 1
fi

if grep -qE '^\s*UMASK\s+' "$TARGET_FILE"; then
    # UMASK exists, update it
    sed -i "s/^\(\s*UMASK\s\+\)[0-9]*/\1$NEW_UMASK/" "$TARGET_FILE"
    ret=$?
else
    # UMASK does not exist, add it
    echo -e "\n# Added by script\nUMASK           $NEW_UMASK" >> "$TARGET_FILE"
    ret=$?
fi

if [[ $ret -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi