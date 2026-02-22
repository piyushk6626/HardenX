#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

MODE="$1"
CONFIG_FILE="/etc/audit/auditd.conf"

if ! [[ "$MODE" =~ ^[0-7]{3,4}$ ]]; then
    echo "false"
    exit 1
fi

if ! [[ -f "$CONFIG_FILE" && -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

if sed -i "s/^\s*log_file\s*=.*/log_file = $MODE/" "$CONFIG_FILE"; then
    echo "true"
else
    echo "false"
fi