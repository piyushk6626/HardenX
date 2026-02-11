#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "false"
    exit 1
fi

STATE="$1"
CONFIG_FILE="/etc/modprobe.d/disable-hfs.conf"

case "$STATE" in
    disabled)
        if ! echo "blacklist hfs" > "$CONFIG_FILE"; then
            echo "false"
            exit 1
        fi

        if lsmod | grep -q "^hfs\s"; then
            if ! modprobe -r hfs; then
                rm -f "$CONFIG_FILE"
                echo "false"
                exit 1
            fi
        fi
        echo "true"
        ;;

    enabled)
        if [ -f "$CONFIG_FILE" ]; then
            if ! rm "$CONFIG_FILE"; then
                echo "false"
                exit 1
            fi
        fi
        echo "true"
        ;;

    *)
        echo "false"
        exit 1
        ;;
esac