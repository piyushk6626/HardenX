#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ! [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

MAX_SIZE="$1"
CONF_FILE="/etc/audit/auditd.conf"
PARAM="max_log_file"

if [[ ! -f "$CONF_FILE" ]]; then
    echo "false"
    exit 1
fi

# Check if the parameter exists (commented or not) and update it
if grep -q -E "^\s*#*\s*${PARAM}\s*=" "$CONF_FILE"; then
    sed -i -E "s/^\s*#*\s*${PARAM}\s*=.*/${PARAM} = ${MAX_SIZE}/" "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    # If it doesn't exist, add it to the end of the file
    echo "${PARAM} = ${MAX_SIZE}" >> "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

# Restart the auditd service to apply changes
if systemctl restart auditd &>/dev/null; then
    echo "true"
else
    echo "false"
fi