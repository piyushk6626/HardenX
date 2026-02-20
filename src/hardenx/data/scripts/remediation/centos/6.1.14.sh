#!/bin/bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

readonly LOG_LEVEL="$1"
readonly CONFIG_FILE="/etc/ssh/sshd_config"
readonly TEMP_FILE=$(mktemp)

trap 'rm -f "$TEMP_FILE"' EXIT

if grep -qE '^[[:space:]]*#?[[:space:]]*LogLevel' "$CONFIG_FILE"; then
    sed "s/^[[:space:]]*#?[[:space:]]*LogLevel.*/LogLevel $LOG_LEVEL/" "$CONFIG_FILE" > "$TEMP_FILE"
else
    cp "$CONFIG_FILE" "$TEMP_FILE"
    echo "LogLevel $LOG_LEVEL" >> "$TEMP_FILE"
fi

if ! mv "$TEMP_FILE" "$CONFIG_FILE"; then
    echo "false"
    exit 1
fi

if ! systemctl restart sshd; then
    echo "false"
    exit 1
fi

echo "true"