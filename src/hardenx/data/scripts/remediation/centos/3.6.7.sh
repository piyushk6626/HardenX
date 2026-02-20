#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

PERMISSIONS="$1"
TARGET_DIR="/etc/cron.d"

if ! [[ "$PERMISSIONS" =~ ^[0-7]{3,4}$ ]]; then
    echo "false"
    exit 1
fi

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "false"
    exit 1
fi

if chown root:root "$TARGET_DIR" && chmod "$PERMISSIONS" "$TARGET_DIR"; then
    echo "true"
else
    echo "false"
fi