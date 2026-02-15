#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

OWNER="$1"

if ! id -u "$OWNER" &>/dev/null; then
    echo "false"
    exit 1
fi

LOG_FILE_PATH=$(awk -F'=' '/^[[:space:]]*log_file/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2; exit}' /etc/audit/auditd.conf)

if [ -z "$LOG_FILE_PATH" ] || [ ! -f "$LOG_FILE_PATH" ]; then
    echo "false"
    exit 1
fi

if chown "$OWNER" "$LOG_FILE_PATH" &>/dev/null; then
    echo "true"
else
    echo "false"
fi