#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
   echo "false"
   exit 1
fi

DESIRED_STATE="$1"

case "${DESIRED_STATE}" in
    disabled)
        if systemctl stop avahi-daemon && systemctl disable avahi-daemon; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    'not installed')
        if apt-get purge -y avahi-daemon; then
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