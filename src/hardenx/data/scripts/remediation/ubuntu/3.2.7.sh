#!/bin/bash

if [[ $EUID -ne 0 || $# -ne 1 ]]; then
   echo "false"
   exit 1
fi

case "$1" in
    active)
        systemctl enable --now systemd-timesyncd &>/dev/null
        ;;
    inactive)
        systemctl disable --now systemd-timesyncd &>/dev/null
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac

if [[ $? -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi