#!/usr/bin/env bash

log_file_path=$(grep -E '^\s*log_file\s*=' /etc/audit/auditd.conf | awk -F'=' '{print $2}' | xargs)

if [[ -n "$log_file_path" ]]; then
    audit_dir=$(dirname "$log_file_path")
    if [[ -d "$audit_dir" ]]; then
        stat -c "%a" "$audit_dir"
    fi
fi