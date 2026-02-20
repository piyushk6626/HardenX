#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

VALUE="$1"

if [[ ! "$VALUE" =~ ^[01]$ ]]; then
    echo "false"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "false"
    exit 1
fi

PARAM="net.ipv4.conf.all.log_martians"
CONFIG_FILE="/etc/sysctl.d/99-log-martians.conf"

if ! echo "${PARAM} = ${VALUE}" > "${CONFIG_FILE}"; then
    echo "false"
    exit 1
fi

if ! sysctl -w "${PARAM}=${VALUE}" &>/dev/null; then
    rm -f "${CONFIG_FILE}" &>/dev/null
    echo "false"
    exit 1
fi

echo "true"
exit 0