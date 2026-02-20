#!/bin/bash

BANNER_PATH="$1"
SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

if [[ "${EUID}" -ne 0 ]]; then
    false
    exit 1
fi

if [[ "$#" -ne 1 ]]; then
    false
    exit 1
fi

if [[ ! -f "${BANNER_PATH}" ]]; then
    false
    exit 1
fi

if [[ ! -w "${SSHD_CONFIG_FILE}" ]]; then
    false
    exit 1
fi

if grep -qE '^\s*#?\s*Banner\s' "${SSHD_CONFIG_FILE}"; then
    sed -i.bak "s|^\s*#*\s*Banner.*|Banner ${BANNER_PATH}|" "${SSHD_CONFIG_FILE}"
    op_status=$?
else
    echo "" >> "${SSHD_CONFIG_FILE}"
    echo "Banner ${BANNER_PATH}" >> "${SSHD_CONFIG_FILE}"
    op_status=$?
fi

if [[ "${op_status}" -eq 0 ]]; then
    # Clean up backup file on success
    rm -f "${SSHD_CONFIG_FILE}.bak"
    true
else
    # Restore from backup on failure
    if [[ -f "${SSHD_CONFIG_FILE}.bak" ]]; then
        mv "${SSHD_CONFIG_FILE}.bak" "${SSHD_CONFIG_FILE}" >/dev/null 2>&1
    fi
    false
fi