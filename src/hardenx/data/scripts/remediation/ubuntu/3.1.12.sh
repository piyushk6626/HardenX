#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   exit 1
fi

if [[ $# -ne 1 ]]; then
    exit 1
fi

STATE="$1"

case "$STATE" in
    "Disabled")
        if systemctl stop rpcbind.service &>/dev/null && \
           systemctl disable rpcbind.service &>/dev/null && \
           systemctl stop rpcbind.socket &>/dev/null && \
           systemctl disable rpcbind.socket &>/dev/null; then
            true
        else
            false
        fi
        ;;
    "Not Installed")
        if apt-get remove --purge -y rpcbind &>/dev/null; then
            true
        else
            false
        fi
        ;;
    *)
        false
        ;;
esac