#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

STATE=$1
KEY="net.ipv4.tcp_syncookies"
CONF_FILE="/etc/sysctl.d/99-tcp-syncookies.conf"

if [[ "$STATE" != "1" && "$STATE" != "0" ]]; then
    echo "false"
    exit 1
fi

# Apply the setting to the live system
if ! sysctl -w "${KEY}=${STATE}" &>/dev/null; then
    echo "false"
    exit 1
fi

# Make the setting persistent
# Ensure config directory exists
mkdir -p "$(dirname "$CONF_FILE")"

# If the key already exists in the file (commented or not), update it
if grep -qE "^\s*#?\s*${KEY}\s*=" "$CONF_FILE" &>/dev/null; then
    if ! sed -i -E "s/^\s*#?\s*${KEY}\s*=.*/${KEY} = ${STATE}/" "$CONF_FILE"; then
        echo "false"
        exit 1
    fi
# Otherwise, add the key to the file
else
    if ! echo "${KEY} = ${STATE}" >> "$CONF_FILE"; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0