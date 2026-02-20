#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

PERMISSION_CODE="$1"
TARGET_DIR="/var/log/journal"

if ! [[ "$PERMISSION_CODE" =~ ^[0-7]{3,4}$ ]]; then
    echo "false"
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "false"
    exit 1
fi

if chmod "$PERMISSION_CODE" "$TARGET_DIR" && \
   chown "root:systemd-journal" "$TARGET_DIR" && \
   chmod g+s "$TARGET_DIR"; then
    echo "true"
else
    echo "false"
fi