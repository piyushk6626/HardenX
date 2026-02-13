#!/usr/bin/env bash

if [[ "$#" -ne 1 ]] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

PARAM="net.ipv4.icmp_ignore_bogus_error_responses"
VALUE="$1"
CONF_FILE="/etc/sysctl.d/99-icmp-bogus-responses.conf"

# Apply setting to live kernel
if ! sysctl -w "${PARAM}=${VALUE}" >/dev/null 2>&1; then
    echo "false"
    exit 1
fi

# Make setting persistent across reboots
if ! grep -q "^\s*${PARAM}\s*=" "$CONF_FILE" 2>/dev/null; then
    # Setting does not exist, append it
    if ! echo "${PARAM} = ${VALUE}" >> "$CONF_FILE"; then
        echo "false"
        exit 1
    fi
else
    # Setting exists, update it
    if ! sed -i "s/^\s*${PARAM}\s*=.*/${PARAM} = ${VALUE}/" "$CONF_FILE"; then
        echo "false"
        exit 1
    fi
fi

echo "true"