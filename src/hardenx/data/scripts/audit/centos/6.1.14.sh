#!/usr/bin/env bash

# Find an active (uncommented) LogLevel setting.
# The regex looks for lines that start with optional whitespace, then "LogLevel".
log_level=$(grep -i '^[[:space:]]*LogLevel' /etc/ssh/sshd_config | awk '{print $2}')

# Use parameter expansion: If $log_level is not set or is null, use "INFO" as the default.
echo "${log_level:-INFO}"