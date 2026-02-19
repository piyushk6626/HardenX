#!/bin/bash

CONFIG_FILE="/etc/ssh/sshd_config"

if [[ ! -r "$CONFIG_FILE" ]]; then
    echo "Not Configured"
    exit 0
fi

banner_line=$(grep -E '^[[:space:]]*Banner[[:space:]]+' "$CONFIG_FILE" | head -n 1)

if [[ -n "$banner_line" ]]; then
    echo "$banner_line" | sed -E 's/^[[:space:]]*Banner[[:space:]]+//'
else
    echo "Not Configured"
fi