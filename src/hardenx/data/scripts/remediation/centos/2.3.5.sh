#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "false"
    exit 1
fi

OWNERSHIP=$1
PERMISSIONS=$2
TARGET_FILE="/etc/issue.net"

if chown "$OWNERSHIP" "$TARGET_FILE" &>/dev/null && chmod "$PERMISSIONS" "$TARGET_FILE" &>/dev/null; then
    echo "true"
else
    echo "false"
fi