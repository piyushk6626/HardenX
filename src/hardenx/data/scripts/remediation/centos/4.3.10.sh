#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

STATE=$1
CONFIG_FILE="/etc/sysctl.d/99-syncookies.conf"

if [[ "$STATE" != "1" && "$STATE" != "0" ]]; then
    echo "false"
    exit 1
fi

# Run the privileged commands in a subshell with 'set -e'
# to ensure that any failure causes the subshell to exit with an error code.
(
    set -e
    echo "net.ipv4.tcp_syncookies = $STATE" > "$CONFIG_FILE"
    sysctl -p "$CONFIG_FILE" &>/dev/null
)

if [[ $? -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi