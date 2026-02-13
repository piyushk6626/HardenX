#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

case "$1" in
    enabled)
        if nmcli radio wifi on &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    disabled)
        if nmcli radio wifi off &>/dev/null; then
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
