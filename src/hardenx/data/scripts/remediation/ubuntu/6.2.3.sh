#!/usr/bin/env bash

if [[ $EUID -ne 0 ]] || [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

LOG_FILE_PATH="$1"
SUDOERS_CONFIG_FILE="/etc/sudoers.d/logfile_config"

# Ensure the parent directory for the log file exists
LOG_PARENT_DIR=$(dirname "$LOG_FILE_PATH")
if ! mkdir -p "$LOG_PARENT_DIR"; then
    echo "false"
    exit 1
fi

# Create the configuration file
if ! echo "Defaults logfile=$LOG_FILE_PATH" > "$SUDOERS_CONFIG_FILE"; then
    echo "false"
    exit 1
fi

# Set the required permissions
if ! chmod 0440 "$SUDOERS_CONFIG_FILE"; then
    rm -f "$SUDOERS_CONFIG_FILE"
    echo "false"
    exit 1
fi

echo "true"