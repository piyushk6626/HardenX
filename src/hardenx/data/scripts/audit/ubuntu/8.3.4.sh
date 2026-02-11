#!/usr/bin/env bash

# This script extracts the value of space_left_action from /etc/audit/auditd.conf

# Check if the file exists and is readable
if [ ! -r "/etc/audit/auditd.conf" ]; then
    exit 1
fi

# Find the line, remove leading/trailing whitespace, and print the value
grep -E '^\s*space_left_action\s*=' /etc/audit/auditd.conf | awk -F '=' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}'