#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    exit 1
fi

DESIRED_STATE="$1"
CONFIG_FILE="/etc/audit/auditd.conf"
SETTING_KEY="admin_space_left_action"

if [[ ! -w "$CONFIG_FILE" ]]; then
    exit 1
fi

if grep -qE "^\s*${SETTING_KEY}\s*=" "$CONFIG_FILE"; then
    sed -i "s/^\s*${SETTING_KEY}\s*=.*/${SETTING_KEY} = ${DESIRED_STATE}/" "$CONFIG_FILE"
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
else
    if ! (echo "" >> "$CONFIG_FILE" && echo "${SETTING_KEY} = ${DESIRED_STATE}" >> "$CONFIG_FILE"); then
        exit 1
    fi
fi

if ! pkill -HUP auditd; then
    exit 1
fi

exit 0