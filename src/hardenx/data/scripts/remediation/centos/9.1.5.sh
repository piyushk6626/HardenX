#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

TARGET_FILE="/etc/shadow"

read -r PERMS OWNER GROUP <<< "$1"

if [ -z "$PERMS" ] || [ -z "$OWNER" ] || [ -z "$GROUP" ]; then
    echo "false"
    exit 1
fi

if chmod "$PERMS" "$TARGET_FILE" && \
   chown "$OWNER" "$TARGET_FILE" && \
   chgrp "$GROUP" "$TARGET_FILE"; then
    echo "true"
else
    echo "false"
fi