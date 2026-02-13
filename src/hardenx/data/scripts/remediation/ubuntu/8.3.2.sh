#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

readonly DESIRED_STATE="$1"
readonly CONFIG_FILE="/etc/audit/auditd.conf"

if ! [[ -f "${CONFIG_FILE}" && -w "${CONFIG_FILE}" ]]; then
    echo "false"
    exit 1
fi

if grep -q -E "^\s*max_log_file_action\s*=" "${CONFIG_FILE}"; then
    sed -i "s/^\s*max_log_file_action\s*=.*/max_log_file_action = ${DESIRED_STATE}/" "${CONFIG_FILE}"
else
    echo "max_log_file_action = ${DESIRED_STATE}" >> "${CONFIG_FILE}"
fi

if [[ $? -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi