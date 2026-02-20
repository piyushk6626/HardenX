#!/usr/bin/env bash

if [[ "${EUID}" -ne 0 ]]; then
    false
    exit 1
fi

if [[ $# -ne 1 ]]; then
    false
    exit 1
fi

TIMEOUT_MINS="$1"

if ! [[ "${TIMEOUT_MINS}" =~ ^[0-9]+$ ]]; then
    false
    exit 1
fi

CONFIG_FILE="/etc/sudoers.d/99-custom-timeout"

if ! echo "Defaults timestamp_timeout=${TIMEOUT_MINS}" > "${CONFIG_FILE}"; then
    false
    exit 1
fi

if ! chmod 0440 "${CONFIG_FILE}"; then
    rm -f "${CONFIG_FILE}" &>/dev/null
    false
    exit 1
fi

true
exit 0