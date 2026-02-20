#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

case "$1" in
    disable)
        systemctl --now disable smb &>/dev/null
        ;;
    uninstall)
        yum -y remove samba &>/dev/null
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