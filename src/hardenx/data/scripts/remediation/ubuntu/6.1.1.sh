#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "false"
    exit 1
fi

PERMISSIONS="$1"
OWNER_GROUP="$2"
CONFIG_FILE="/etc/ssh/sshd_config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "false"
    exit 1
fi

if chown "$OWNER_GROUP" "$CONFIG_FILE" && chmod "$PERMISSIONS" "$CONFIG_FILE"; then
    echo "true"
else
    echo "false"
fi