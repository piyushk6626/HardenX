#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

TARGET="/etc/motd"
INPUT="$1"

PERMS=$(echo "$INPUT" | awk '{print $1}')
OWNERSHIP=$(echo "$INPUT" | awk '{print $2}')

if [ -z "$PERMS" ] || [ -z "$OWNERSHIP" ]; then
    echo "false"
    exit 1
fi

if chmod "$PERMS" "$TARGET" 2>/dev/null && chown "$OWNERSHIP" "$TARGET" 2>/dev/null; then
    echo "true"
else
    echo "false"
fi