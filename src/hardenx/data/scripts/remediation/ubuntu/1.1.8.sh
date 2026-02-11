#!/usr/bin/env bash

if [[ "$#" -ne 1 || "$1" != "Disabled" ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/modprobe.d/disable-udf.conf"

echo "install udf /bin/true" > "$CONFIG_FILE"
if [[ $? -ne 0 ]]; then
    echo "false"
    exit 1
fi

if lsmod | grep -q -w "udf"; then
    rmmod udf &>/dev/null || true
fi

echo "true"
exit 0