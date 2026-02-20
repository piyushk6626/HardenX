#!/usr/bin/env bash

CONFIG_FILE="/etc/login.defs"
DAYS="$1"

if [[ $# -ne 1 ]] || ! [[ "$DAYS" =~ ^[0-9]+$ ]] || [[ "$EUID" -ne 0 ]] || [[ ! -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Check if an uncommented PASS_MIN_DAYS line already exists
if grep -qE '^[[:space:]]*PASS_MIN_DAYS[[:space:]]+' "$CONFIG_FILE"; then
    # If it exists, update it using sed
    sed -i "s/^\(PASS_MIN_DAYS[[:space:]]\+\)[0-9]*/\1$DAYS/" "$CONFIG_FILE"
else
    # If it does not exist, append it to the file
    echo "PASS_MIN_DAYS    $DAYS" >> "$CONFIG_FILE"
fi

if [[ $? -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi