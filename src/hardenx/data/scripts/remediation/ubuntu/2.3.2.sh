#!/bin/bash

if [[ $EUID -ne 0 ]] || [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

BANNER_TEXT="$1"
TARGET_FILE="/etc/issue.net"

if printf "%s\n" "$BANNER_TEXT" > "$TARGET_FILE" && \
   chmod 644 "$TARGET_FILE" && \
   chown root:root "$TARGET_FILE"; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi