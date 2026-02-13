#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

case "$1" in
    enabled)
        systemctl enable --now ufw &>/dev/null
        ;;
    disabled)
        systemctl disable --now ufw &>/dev/null
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo "true"
else
    echo "false"
fi