#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ -z "$1" ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/audit/auditd.conf"
SETTING="max_log_file_action"
VALUE="$1"

if [ ! -f "$CONFIG_FILE" ] || [ ! -w "$CONFIG_FILE" ]; then
    echo "false"
    exit 1
fi

if grep -q -E "^\s*${SETTING}\s*=" "$CONFIG_FILE"; then
    sed -i "s#^\s*${SETTING}\s*=.*#${SETTING} = ${VALUE}#" "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    if [[ "$(tail -c1 "$CONFIG_FILE")" != "" ]]; then
        echo "" >> "$CONFIG_FILE"
    fi
    echo "${SETTING} = ${VALUE}" >> "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

if systemctl restart auditd &> /dev/null; then
    echo "true"
else
    echo "false"
fi