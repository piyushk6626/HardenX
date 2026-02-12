#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
   echo "false"
   exit 1
fi

ACTION="$1"

case "$ACTION" in
    "Disabled")
        if systemctl stop smbd &>/dev/null && systemctl disable smbd &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    "Not Installed")
        if apt-get purge -y samba* &>/dev/null && apt-get autoremove -y &>/dev/null; then
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