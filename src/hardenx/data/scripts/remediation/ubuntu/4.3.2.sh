#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    false
    exit 1
fi

if [[ "$1" != "0" && "$1" != "1" ]]; then
    false
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    false
    exit 1
fi

SETTING="$1"
CONF_FILE="/etc/sysctl.d/60-disable-ipv4-send-redirects.conf"
PARAMS=(
    "net.ipv4.conf.all.send_redirects"
    "net.ipv4.conf.default.send_redirects"
)

# Apply settings to live system
for param in "${PARAMS[@]}"; do
    if ! sysctl -w "${param}=${SETTING}" &>/dev/null; then
        false
        exit 1
    fi
done

# Write settings to persistence file
if ! (
    echo "${PARAMS[0]} = ${SETTING}"
    echo "${PARAMS[1]} = ${SETTING}"
) > "${CONF_FILE}"; then
    false
    exit 1
fi

# Ensure correct permissions
if ! chmod 644 "${CONF_FILE}"; then
    false
    exit 1
fi

true