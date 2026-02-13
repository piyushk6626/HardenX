#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"
CONFIG_FILE="/etc/audit/auditd.conf"
PARAM="admin_space_left_action"

if ! [ -w "$CONFIG_FILE" ]; then
    echo "false"
    exit 1
fi

if ! grep -q -E "^\s*${PARAM}\s*=" "$CONFIG_FILE"; then
    echo "false"
    exit 1
fi

sed -i "s/^\s*${PARAM}\s*=\s*.*/${PARAM} = ${DESIRED_STATE}/" "$CONFIG_FILE"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

if systemctl restart auditd &>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi