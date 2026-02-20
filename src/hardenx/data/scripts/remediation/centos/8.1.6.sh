#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    enabled)
        if systemctl enable --now rsyslog &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    disabled)
        if systemctl disable --now rsyslog &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac
