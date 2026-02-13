#!/usr/bin/env bash

if [[ "$1" != "remove" ]]; then
    exit 1
fi

SHELLS_FILE="/etc/shells"

if [[ ! -w "$SHELLS_FILE" ]]; then
    echo "false"
    exit 1
fi

sed -i.bak \
    -e '\|^/usr/sbin/nologin$|d' \
    -e '\|^/sbin/nologin$|d' \
    "$SHELLS_FILE" 2>/dev/null

if [[ $? -eq 0 ]]; then
    rm -f "${SHELLS_FILE}.bak"
    echo "true"
else
    # Attempt to restore from backup if sed failed
    if [[ -f "${SHELLS_FILE}.bak" ]]; then
        mv "${SHELLS_FILE}.bak" "$SHELLS_FILE" 2>/dev/null
    fi
    echo "false"
fi