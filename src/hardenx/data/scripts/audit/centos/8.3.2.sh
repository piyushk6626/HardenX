#!/bin/bash

# Path to the auditd configuration file
AUDITD_CONF="/etc/audit/auditd.conf"

# Check if the file exists and is readable
if [[ ! -r "$AUDITD_CONF" ]]; then
    exit 1
fi

# Extract the value of max_log_file_action
# - Use grep to find the line, ignoring comments and case
# - Use awk to split on '=' and print the second field, trimming whitespace
grep -i '^\s*max_log_file_action' "$AUDITD_CONF" | awk -F'=' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}'
