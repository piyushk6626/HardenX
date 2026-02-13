#!/bin/bash

if [[ $# -ne 1 || -z "$1" ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/audit/auditd.conf"
SETTING="space_left_action"
ACTION="$1"

if [[ ! -f "${CONFIG_FILE}" || ! -w "${CONFIG_FILE}" ]]; then
    echo "false"
    exit 1
fi

# Check if the setting already exists (case-sensitive, whole word)
if grep -qE "^[[:space:]]*${SETTING}[[:space:]]*=" "${CONFIG_FILE}"; then
    # Setting exists, so replace its value
    sed -i "s/^\([[:space:]]*${SETTING}[[:space:]]*=[[:space:]]*\).*/\1${ACTION}/" "${CONFIG_FILE}"
    exit_code=$?
else
    # Setting does not exist, so append it
    echo "${SETTING} = ${ACTION}" >> "${CONFIG_FILE}"
    exit_code=$?
fi

if [[ ${exit_code} -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi