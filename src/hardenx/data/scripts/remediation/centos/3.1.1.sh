#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    disabled)
        if systemctl stop autofs &>/dev/null && systemctl disable autofs &>/dev/null; then
            echo "true"
            exit 0
        else
            echo "false"
            exit 1
        fi
        ;;
    masked)
        if systemctl mask autofs &>/dev/null; then
            echo "true"
            exit 0
        else
            echo "false"
            exit 1
        fi
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac