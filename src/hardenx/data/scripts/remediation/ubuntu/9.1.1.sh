#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

PERMS_REQUESTED=$1
TARGET_FILE="/etc/passwd"

chmod "$PERMS_REQUESTED" "$TARGET_FILE" &>/dev/null

CURRENT_PERMS=$(stat -c "%a" "$TARGET_FILE")

if [ "$CURRENT_PERMS" == "$PERMS_REQUESTED" ]; then
    echo "true"
else
    echo "false"
fi