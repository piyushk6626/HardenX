#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

PERM_MODE="$1"
AUDIT_CONF="/etc/audit/auditd.conf"

if [ ! -r "$AUDIT_CONF" ]; then
    echo "false"
    exit 1
fi

log_file_path=$(awk -F'=' '/^\s*log_file\s*=/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$AUDIT_CONF")

if [ -z "$log_file_path" ]; then
    echo "false"
    exit 1
fi

log_dir=$(dirname "$log_file_path")

if [ ! -d "$log_dir" ]; then
    echo "false"
    exit 1
fi

if chmod "$PERM_MODE" "$log_dir" &>/dev/null; then
    echo "true"
else
    echo "false"
fi