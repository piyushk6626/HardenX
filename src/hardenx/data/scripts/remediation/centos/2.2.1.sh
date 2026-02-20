#!/usr/bin/env bash

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ "$#" -ne 1 ]] || ! [[ "$1" =~ ^[0-2]$ ]]; then
    echo "false"
    exit 1
fi

VALUE="$1"
CONF_FILE="/etc/sysctl.d/99-custom-randomize-va-space.conf"

if ! sysctl -w "kernel.randomize_va_space=${VALUE}" &>/dev/null; then
    echo "false"
    exit 1
fi

if ! echo "kernel.randomize_va_space = ${VALUE}" > "${CONF_FILE}"; then
    echo "false"
    exit 1
fi

echo "true"
exit 0