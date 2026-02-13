#!/bin/bash

if [ "$(id -u)" -ne 0 ] || [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

REMOTE_HOST=$1
CONF_FILE="/etc/rsyslog.d/99-remote.conf"

# Create the configuration file
if ! echo "*.* ${REMOTE_HOST}" > "${CONF_FILE}"; then
    echo "false"
    exit 1
fi

# Restart the rsyslog service
if ! systemctl restart rsyslog &>/dev/null; then
    # If restart fails, remove the potentially bad config file
    rm -f "${CONF_FILE}" &>/dev/null
    echo "false"
    exit 1
fi

echo "true"