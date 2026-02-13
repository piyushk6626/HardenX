#!/bin/bash

if [[ "$#" -ne 1 || ! "$1" =~ ^-?[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/security/pwquality.conf"
VALUE="$1"
EXIT_CODE=1

if ! touch "$CONFIG_FILE" &>/dev/null; then
    echo "false"
    exit 1
fi

if grep -q -E '^[[:space:]]*maxsequence' "$CONFIG_FILE"; then
    sed -i -E "s/^[[:space:]]*#?[[:space:]]*maxsequence[[:space:]]*=.*$/maxsequence = $VALUE/" "$CONFIG_FILE"
    EXIT_CODE=$?
else
    echo "maxsequence = $VALUE" >> "$CONFIG_FILE"
    EXIT_CODE=$?
fi

if [[ $EXIT_CODE -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi