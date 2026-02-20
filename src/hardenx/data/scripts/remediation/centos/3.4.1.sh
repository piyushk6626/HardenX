#!/usr/bin/env bash

# This script must be run as root
if [[ "${EUID}" -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Check for exactly one argument
if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

# Check if the argument is an empty string
if [[ -z "$1" ]]; then
    echo "false"
    exit 1
fi

SERVERS="$1"
CONF_FILE="/etc/systemd/timesyncd.conf"

# Check if the configuration file exists and is writable
if [[ ! -f "$CONF_FILE" ]] || [[ ! -w "$CONF_FILE" ]]; then
    echo "false"
    exit 1
fi

# Use a temporary file to safely edit
TMP_FILE=$(mktemp)
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi
# Ensure temp file is cleaned up on exit
trap 'rm -f -- "$TMP_FILE"' EXIT

# Check if an NTP line already exists (commented or not)
if grep -qE '^[[:space:]]*#?NTP=' "$CONF_FILE"; then
    # Line exists, replace it (handles commented and uncommented)
    sed "s/^[[:space:]]*#?NTP=.*/NTP=${SERVERS}/" "$CONF_FILE" > "$TMP_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    # Line does not exist, add it under the [Time] section
    if grep -qE '^[[:space:]]*\[Time\]' "$CONF_FILE"; then
        sed "/^[[:space:]]*\[Time\]/a NTP=${SERVERS}" "$CONF_FILE" > "$TMP_FILE"
        if [[ $? -ne 0 ]]; then
            echo "false"
            exit 1
        fi
    else
        # [Time] section is missing, which is an invalid state
        echo "false"
        exit 1
    fi
fi

# Atomically replace the old config file with the new one
cat "$TMP_FILE" > "$CONF_FILE"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Restart the service to apply changes
if ! systemctl restart systemd-timesyncd; then
    echo "false"
    exit 1
fi

echo "true"
exit 0