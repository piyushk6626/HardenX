#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

MODE="$1"
CONFIG_FILE="/etc/rsyslog.conf"

if ! [[ "$MODE" =~ ^[0-7]{3,4}$ ]]; then
    echo "false"
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]] || [[ ! -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

if grep -qE "^\s*\$FileCreateMode" "$CONFIG_FILE"; then
    sed -i -E "s/^\s*\\\$FileCreateMode.*/\\\$FileCreateMode $MODE/" "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    if ! echo "\$FileCreateMode $MODE" >> "$CONFIG_FILE"; then
        echo "false"
        exit 1
    fi
fi

if systemctl restart rsyslog &>/dev/null; then
    echo "true"
else
    echo "false"
fi