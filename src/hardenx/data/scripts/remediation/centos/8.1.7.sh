#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONF_FILE="/etc/systemd/journald.conf"
SETTING_KEY="ForwardToSyslog"
SETTING_VALUE="$1"
TARGET_LINE="${SETTING_KEY}=${SETTING_VALUE}"

# Check if the config file exists and is writable
if [[ ! -f "$CONF_FILE" ]] || [[ ! -w "$CONF_FILE" ]]; then
    echo "false"
    exit 1
fi

# Check if the setting already exists (commented or uncommented)
if grep -qE "^\s*#?\s*${SETTING_KEY}=" "$CONF_FILE"; then
    # If it exists, replace the line
    sed -i -E "s/^\s*#?\s*${SETTING_KEY}=.*/${TARGET_LINE}/" "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    # If it doesn't exist, add it under the [Journal] section.
    # We assume the [Journal] section exists.
    sed -i "/\[Journal\]/a ${TARGET_LINE}" "$CONF_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

# Restart the service to apply the new configuration
if systemctl restart systemd-journald &>/dev/null; then
    echo "true"
else
    echo "false"
fi