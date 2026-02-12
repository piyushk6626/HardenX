#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

TARGET_FILE="/etc/issue"
OWNERSHIP_PERMS="$1"

OWNER_GROUP=$(echo "$OWNERSHIP_PERMS" | awk '{print $1}')
PERMISSIONS=$(echo "$OWNERSHIP_PERMS" | awk '{print $2}')

if [ -z "$OWNER_GROUP" ] || [ -z "$PERMISSIONS" ]; then
    echo "false"
    exit 1
fi

# Suppress command error messages to only output true/false
if chown "$OWNER_GROUP" "$TARGET_FILE" 2>/dev/null && chmod "$PERMISSIONS" "$TARGET_FILE" 2>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi