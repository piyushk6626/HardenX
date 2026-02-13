#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

UNLOCK_TIME=$1
CONFIG_FILE="/etc/security/faillock.conf"

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ] || [ ! -w "$CONFIG_FILE" ]; then
    echo "false"
    exit 1
fi

if grep -qE "^\s*#?\s*unlock_time\s*=" "$CONFIG_FILE"; then
    # Parameter exists (commented or uncommented), so replace it.
    sed -i "s/^\s*#*\s*unlock_time\s*=.*/unlock_time = ${UNLOCK_TIME}/" "$CONFIG_FILE"
    if [[ $? -eq 0 ]]; then
        echo "true"
    else
        echo "false"
    fi
else
    # Parameter does not exist, so append it.
    echo "unlock_time = ${UNLOCK_TIME}" >> "$CONFIG_FILE"
    if [[ $? -eq 0 ]]; then
        echo "true"
    else
        echo "false"
    fi
fi