#!/usr/bin/env bash

# Fail on any error
set -e

CONFIG_FILE="/etc/audit/auditd.conf"
LOG_MODE="$1"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

# Check for correct number of arguments
if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

# Basic validation for file mode format
if ! [[ "$LOG_MODE" =~ ^[0-7]{3,4}$ ]]; then
    echo "false"
    exit 1
fi

# Ensure the config file exists and is writable
if [[ ! -f "$CONFIG_FILE" ]] || [[ ! -w "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

# Check if the log_file parameter exists (commented or not)
if grep -q -E "^\s*#*\s*log_file\s*=" "$CONFIG_FILE"; then
    # Parameter exists, uncomment and set the value
    if ! sed -i -E "s/^\s*#*\s*log_file\s*=.*/log_file = ${LOG_MODE}/" "$CONFIG_FILE"; then
        echo "false"
        exit 1
    fi
else
    # Parameter does not exist, add it to the end of the file
    if ! echo "log_file = ${LOG_MODE}" >> "$CONFIG_FILE"; then
        echo "false"
        exit 1
    fi
fi

# Restart auditd service to apply changes
if ! systemctl restart auditd; then
    echo "false"
    exit 1
fi

echo "true"
exit 0