#!/bin/bash

if [ "$#" -ne 1 ] || ! [[ "$1" =~ ^[0-7]{3,4}$ ]]; then
    echo "false"
    exit 1
fi

mode="$1"
config_file="/etc/audit/auditd.conf"
default_dir="/var/log/audit"
audit_dir=""

if [ -r "$config_file" ]; then
    log_file_path=$(grep -oP '^\s*log_file\s*=\s*\K.*' "$config_file")
    if [ -n "$log_file_path" ]; then
        audit_dir=$(dirname "$log_file_path")
    fi
fi

if [ -z "$audit_dir" ]; then
    audit_dir="$default_dir"
fi

if [ -d "$audit_dir" ] && chmod "$mode" "$audit_dir" &>/dev/null; then
    echo "true"
else
    echo "false"
fi