#!/bin/bash

set -e
trap 'echo "false"' ERR

if [[ $# -ne 1 ]] || [[ "$1" != "disabled" ]]; then
    echo "false"
    exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
    echo "false"
    exit 1
fi

readonly MODULE_NAME="dccp"
readonly CONFIG_FILE="/etc/modprobe.d/${MODULE_NAME}-disable.conf"
readonly CONFIG_CONTENT="install ${MODULE_NAME} /bin/true"

echo "${CONFIG_CONTENT}" > "${CONFIG_FILE}"

if lsmod | grep -q "^${MODULE_NAME} "; then
    rmmod "${MODULE_NAME}"
fi

echo "true"
exit 0