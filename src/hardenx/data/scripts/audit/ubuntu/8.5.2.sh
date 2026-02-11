#!/usr/bin/env bash

LOG_FILE_PATH=$(awk -F'=' '/^\s*log_file\s*=/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' /etc/audit/auditd.conf)

if [ -f "$LOG_FILE_PATH" ]; then
    stat -c "%U" "$LOG_FILE_PATH"
fi