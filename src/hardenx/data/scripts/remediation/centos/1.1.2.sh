#!/bin/bash


if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONF_FILE="/etc/modprobe.d/freevxfs-disable.conf"
MODULE_NAME="freevxfs"

if ! echo "install ${MODULE_NAME} /bin/true" > "${CONF_FILE}"; then
    echo "false"
    exit 1
fi

if lsmod | grep -q "^${MODULE_NAME}\s"; then
    if ! modprobe -r "${MODULE_NAME}"; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0
