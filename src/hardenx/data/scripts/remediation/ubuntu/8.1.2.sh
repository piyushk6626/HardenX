#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

PERMISSION_MODE="$1"
TARGET_DIR="/var/log/journal"
OWNER_GROUP="root:systemd-journal"
FILE_PERMS="640"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "false"
    exit 1
fi

if chmod "$PERMISSION_MODE" "$TARGET_DIR" && \
   chown -R "$OWNER_GROUP" "$TARGET_DIR" && \
   find "$TARGET_DIR" -type f -exec chmod "$FILE_PERMS" {} +; then
    echo "true"
else
    echo "false"
fi
