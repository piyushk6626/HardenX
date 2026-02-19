#!/bin/bash

log_file_path=$(awk -F= '/^\s*log_file/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' /etc/audit/auditd.conf)

if [[ -n "$log_file_path" && -e "$log_file_path" ]]; then
    perms=$(stat -c "%a" "$log_file_path")
    printf "Audit log file: %s\nPermissions: %s\n" "$log_file_path" "$perms"
else
    printf "Audit log file not found or path is not set in /etc/audit/auditd.conf\n"
fi