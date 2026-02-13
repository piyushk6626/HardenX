#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

TIMEOUT_VALUE="$1"
CONFIG_FILE="/etc/sudoers.d/99-reauth-timeout"
CONFIG_CONTENT="Defaults timestamp_timeout=${TIMEOUT_VALUE}"

# Write the configuration and check for success
if ! echo "${CONFIG_CONTENT}" > "${CONFIG_FILE}"; then
    echo "false"
    exit 1
fi

# Set permissions and check for success
if ! chmod 0440 "${CONFIG_FILE}"; then
    # Clean up the file if permissions cannot be set correctly
    rm -f "${CONFIG_FILE}" &>/dev/null
    echo "false"
    exit 1
fi

echo "true"
exit 0