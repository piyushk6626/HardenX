#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

PERMISSIONS="$1"
TARGET_FILE="/etc/group-"

if chmod "$PERMISSIONS" "$TARGET_FILE" &>/dev/null; then
    echo "true"
else
    echo "false"
fi