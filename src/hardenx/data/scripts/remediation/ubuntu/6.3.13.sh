#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"
if ! [[ "$VALUE" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONF_FILE="/etc/security/pwquality.conf"
SETTING="maxrepeat"

if [[ ! -f "$CONF_FILE" ]] || [[ ! -w "$CONF_FILE" ]]; then
    echo "false"
    exit 1
fi

if grep -q -E "^\s*#?\s*${SETTING}\s*=" "$CONF_FILE"; then
    sed -i -E "s/^\s*#?\s*${SETTING}\s*=.*/${SETTING} = ${VALUE}/" "$CONF_FILE"
    RC=$?
else
    echo "${SETTING} = ${VALUE}" >> "$CONF_FILE"
    RC=$?
fi

if [[ $RC -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi