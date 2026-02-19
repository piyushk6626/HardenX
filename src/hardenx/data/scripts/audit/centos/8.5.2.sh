#!/usr/bin/env bash

log_file_path=$(grep -E '^\s*log_file\s*=' /etc/audit/auditd.conf | awk -F'=' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')

if [ -n "$log_file_path" ]; then
    log_dir=$(dirname "$log_file_path")
    owner=$(stat -c '%U' "$log_dir")
    printf "Audit log directory: %s\nOwner: %s\n" "$log_dir" "$owner"
else
    printf "No log_file path found in /etc/audit/auditd.conf\n"
fi