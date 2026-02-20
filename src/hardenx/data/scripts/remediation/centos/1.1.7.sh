#!/usr/bin/env bash

set -e

CONF_FILE="/etc/modprobe.d/disable-squashfs.conf"
ACTION="$1"

if [[ $EUID -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

case "$ACTION" in
    Disabled)
        echo 'install squashfs /bin/true' > "$CONF_FILE"
        rmmod squashfs &>/dev/null || true # Attempt unload, but don't fail script if it fails
        echo "true"
        ;;
    Enabled)
        rm -f "$CONF_FILE"
        echo "true"
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac