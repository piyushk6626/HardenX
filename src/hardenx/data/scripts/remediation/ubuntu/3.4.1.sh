#!/usr/bin/env bash

set -e

if [[ $# -ne 1 ]] || [[ -z "$1" ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

NTP_SERVERS="$1"
CONF_FILE="/etc/systemd/timesyncd.conf"

if ! grep -q '^[# ]*NTP=' "$CONF_FILE"; then
    if grep -q '^\s*\[Time\]' "$CONF_FILE"; then
        sed -i "/^\s*\[Time\]/a NTP=$NTP_SERVERS" "$CONF_FILE"
    else
        echo "[Time]" >> "$CONF_FILE"
        echo "NTP=$NTP_SERVERS" >> "$CONF_FILE"
    fi
else
    sed -i "s/^[# ]*NTP=.*/NTP=$NTP_SERVERS/" "$CONF_FILE"
fi

if ! systemctl restart systemd-timesyncd; then
    echo "false"
    exit 1
fi

echo "true"
exit 0