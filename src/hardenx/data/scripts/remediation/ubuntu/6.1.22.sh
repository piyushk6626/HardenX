#!/bin/bash

if [[ "${EUID}" -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"
if [[ "${VALUE}" != "yes" && "${VALUE}" != "no" ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/ssh/sshd_config"
DIRECTIVE="UsePAM"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "false"
    exit 1
fi

# Use a temporary file for atomic operations
TMP_FILE=$(mktemp)
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi
trap 'rm -f "$TMP_FILE"' EXIT

if grep -qE '^[[:space:]]*#?[[:space:]]*'"${DIRECTIVE}"'[[:space:]]+' "${CONFIG_FILE}"; then
    # Directive exists, so we replace it.
    sed -E 's/^[[:space:]]*#?[[:space:]]*'"${DIRECTIVE}"'[[:space:]]+.*$/'"${DIRECTIVE}"' '"${VALUE}"'/' "${CONFIG_FILE}" > "${TMP_FILE}"
else
    # Directive does not exist, so we append it.
    cp "${CONFIG_FILE}" "${TMP_FILE}"
    echo "" >> "${TMP_FILE}"
    echo "${DIRECTIVE} ${VALUE}" >> "${TMP_FILE}"
fi

if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Overwrite the original file
cat "${TMP_FILE}" > "${CONFIG_FILE}"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

# Determine service name (sshd or ssh)
SERVICE_NAME="sshd"
if ! systemctl list-units --type=service | grep -q "${SERVICE_NAME}.service"; then
    SERVICE_NAME="ssh"
fi

# Restart the service
if command -v systemctl &>/dev/null; then
    systemctl restart "${SERVICE_NAME}"
    RESTART_STATUS=$?
elif command -v service &>/dev/null; then
    service "${SERVICE_NAME}" restart
    RESTART_STATUS=$?
else
    RESTART_STATUS=127 # Command not found
fi

if [[ ${RESTART_STATUS} -ne 0 ]]; then
    echo "false"
    exit 1
fi

echo "true"
exit 0