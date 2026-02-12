#!/bin/bash

CONFIG_FILE="/etc/postfix/main.cf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "false"
    exit 1
fi

if ! postconf -e "inet_interfaces = loopback-only" &>/dev/null; then
    echo "false"
    exit 1
fi

if ! systemctl restart postfix &>/dev/null; then
    echo "false"
    exit 1
fi

echo "true"
exit 0