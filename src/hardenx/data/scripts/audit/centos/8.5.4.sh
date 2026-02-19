#!/usr/bin/env bash

LOG_FILE_PATH=$(grep '^[[:space:]]*log_file' /etc/audit/auditd.conf | sed 's/.*=[[:space:]]*//')

if [ -z "$LOG_FILE_PATH" ]; then
    exit 1
fi

AUDIT_LOG_DIR=$(dirname "$LOG_FILE_PATH")

if [ ! -d "$AUDIT_LOG_DIR" ]; then
    exit 1
fi

stat -c "%a" "$AUDIT_LOG_DIR"