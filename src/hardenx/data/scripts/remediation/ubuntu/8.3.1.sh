#!/usr/bin/env bash

CONF_FILE="/etc/audit/auditd.conf"

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"

if ! [[ "$VALUE" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [[ ! -f "$CONF_FILE" ]] || [[ ! -w "$CONF_FILE" ]]; then
    echo "false"
    exit 1
fi

if grep -qE "^\s*max_log_file\s*=" "$CONF_FILE"; then
    sed -i "s/^\s*max_log_file\s*=.*/max_log_file = $VALUE/" "$CONF_FILE"
    RC=$?
else
    echo "max_log_file = $VALUE" >> "$CONF_FILE"
    RC=$?
fi

if [[ $RC -eq 0 ]]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi