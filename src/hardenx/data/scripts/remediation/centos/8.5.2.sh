#!/usr/bin/env bash

if [[ $# -ne 1 ]] || [[ -z "$1" ]]; then
    echo "false"
    exit 1
fi

USERNAME="$1"
AUDIT_CONF="/etc/audit/auditd.conf"

if [[ ! -r "$AUDIT_CONF" ]]; then
    echo "false"
    exit 1
fi

LOG_FILE_PATH=$(sed -n 's/^[[:space:]]*log_file[[:space:]]*=[[:space:]]*\([^[:space:]#]*\).*/\1/p' "$AUDIT_CONF" | sed 's/[[:space:]]*$//')

if [[ -z "$LOG_FILE_PATH" ]]; then
    echo "false"
    exit 1
fi

LOG_DIR=$(dirname "$LOG_FILE_PATH")

if [[ ! -d "$LOG_DIR" ]]; then
    echo "false"
    exit 1
fi

if chown -R "$USERNAME" "$LOG_DIR" &>/dev/null; then
    echo "true"
else
    echo "false"
fi