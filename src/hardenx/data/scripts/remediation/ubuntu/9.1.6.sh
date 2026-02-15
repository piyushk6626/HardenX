#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

TARGET_FILE="/etc/shadow-"

if [ ! -f "$TARGET_FILE" ]; then
    echo "false"
    exit 1
fi

# Use read to parse the argument into two variables
read -r perms owner <<< "$1"

# Check if both variables were populated
if [[ -z "$perms" || -z "$owner" ]]; then
    echo "false"
    exit 1
fi

# Apply permissions and ownership, suppressing command output
if chmod "$perms" "$TARGET_FILE" &>/dev/null && chown "$owner" "$TARGET_FILE" &>/dev/null; then
    echo "true"
else
    echo "false"
fi