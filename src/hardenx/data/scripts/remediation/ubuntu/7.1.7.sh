#!/bin/bash

# This script must be run as root
if [[ "${EUID}" -ne 0 ]]; then
    echo "false"
    exit 1
fi

LOG_FILE="/var/log/uid0_remediation.log"
TARGET_COUNT="0"

# --- Argument Validation ---
if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ "$1" != "${TARGET_COUNT}" ]]; then
    echo "false"
    exit 1
fi

# --- Main Logic ---
UNAUTHORIZED_ACCOUNTS=$(awk -F: '($3 == 0 && $1 != "root") {print $1}' /etc/passwd)
ERROR_FLAG=0

if [ -z "${UNAUTHORIZED_ACCOUNTS}" ]; then
    echo "true"
    exit 0
else
    TIMESTAMP=$(date --iso-8601=seconds)
    echo "${TIMESTAMP}: WARNING - Unauthorized UID 0 accounts found. Attempting remediation." >> "${LOG_FILE}"

    for user in ${UNAUTHORIZED_ACCOUNTS}; do
        echo "${TIMESTAMP}: Found unauthorized UID 0 account: [${user}]." >> "${LOG_FILE}"
        
        # Determine a valid non-interactive shell
        NOLOGIN_SHELL="/sbin/nologin"
        if [ ! -f "${NOLOGIN_SHELL}" ]; then
            NOLOGIN_SHELL="/usr/sbin/nologin"
            if [ ! -f "${NOLOGIN_SHELL}" ]; then
                 NOLOGIN_SHELL="/bin/false" # Fallback
            fi
        fi

        # Attempt to lock the account by setting the shell
        if usermod -s "${NOLOGIN_SHELL}" "${user}"; then
            echo "${TIMESTAMP}: Successfully locked account [${user}] by setting shell to [${NOLOGIN_SHELL}]." >> "${LOG_FILE}"
        else
            echo "${TIMESTAMP}: ERROR - Failed to lock account [${user}]." >> "${LOG_FILE}"
            ERROR_FLAG=1
        fi
    done
fi

# --- Final Result ---
if [[ "${ERROR_FLAG}" -eq 0 ]]; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi