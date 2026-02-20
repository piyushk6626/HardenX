#!/usr/bin/env bash


if [[ "$(id -u)" -ne 0 ]]; then
    echo "false"
    exit 1
fi

CONF_FILE="/etc/modprobe.d/disable-usb-storage.conf"
CONF_CONTENT="install usb-storage /bin/true"
MODULE_NAME="usb_storage"

if ! grep -qFx "$CONF_CONTENT" "$CONF_FILE" &>/dev/null; then
    if ! echo "$CONF_CONTENT" > "$CONF_FILE"; then
        echo "false"
        exit 1
    fi
fi

if lsmod | grep -q "^${MODULE_NAME} "; then
    if ! rmmod "$MODULE_NAME" &>/dev/null; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0
