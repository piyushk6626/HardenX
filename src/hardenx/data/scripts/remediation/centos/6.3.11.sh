#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

VALUE="$1"
CONF_FILE="/etc/security/pwquality.conf"

if ! [[ "$VALUE" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "false"
    exit 1
fi

if [ ! -f "$CONF_FILE" ]; then
    echo "false"
    exit 1
fi

if grep -qE '^[[:space:]]*#?[[:space:]]*difok' "$CONF_FILE"; then
    sed -i "s/^[[:space:]]*#\?[[:space:]]*difok.*/difok = $VALUE/" "$CONF_FILE"
    if [ $? -ne 0 ]; then
        echo "false"
        exit 1
    fi
else
    echo "difok = $VALUE" >> "$CONF_FILE"
    if [ $? -ne 0 ]; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0