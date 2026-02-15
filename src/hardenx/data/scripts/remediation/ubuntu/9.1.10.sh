#!/bin/bash

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
    echo "false"
    exit 1
fi

TARGET_FILE="/etc/security/opasswd"
DESIRED_STATE="$1"

OWNERSHIP="${DESIRED_STATE% *}"
PERMISSIONS="${DESIRED_STATE#* }"

if ! touch "$TARGET_FILE" 2>/dev/null; then
    echo "false"
    exit 1
fi

if chown "$OWNERSHIP" "$TARGET_FILE" 2>/dev/null && chmod "$PERMISSIONS" "$TARGET_FILE" 2>/dev/null; then
    echo "true"
else
    echo "false"
fi