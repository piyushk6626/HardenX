#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/ssh/sshd_config"
PARAM_NAME="MaxAuthTries"
PARAM_VALUE="$1"

if ! [[ -f "$CONFIG_FILE" ]]; then
    echo "false"
    exit 1
fi

if grep -qE "^\s*#?\s*${PARAM_NAME}\s+" "$CONFIG_FILE"; then
    sed -i -E "s/^\s*#*\s*${PARAM_NAME}.*$/${PARAM_NAME} ${PARAM_VALUE}/" "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
else
    echo "${PARAM_NAME} ${PARAM_VALUE}" >> "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        echo "false"
        exit 1
    fi
fi

if systemctl reload sshd &>/dev/null; then
    echo "true"
else
    echo "false"
fi