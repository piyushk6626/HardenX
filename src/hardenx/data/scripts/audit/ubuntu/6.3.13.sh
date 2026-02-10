#!/usr/bin/env bash

CONF_FILE="/etc/security/pwquality.conf"

if [[ ! -r "$CONF_FILE" ]]; then
    echo "0"
    exit 0
fi

value=$(grep -E '^[[:space:]]*maxrepeat[[:space:]]*=' "$CONF_FILE" | awk -F'=' '{print $2}' | awk '{print $1}')

if [[ -z "$value" ]]; then
    echo "0"
else
    echo "$value"
fi