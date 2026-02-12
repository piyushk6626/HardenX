#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

case "$1" in
    "Not Installed")
        apt-get purge -y nfs-kernel-server rpcbind &>/dev/null
        status=$?
        ;;
    "Disabled")
        systemctl is-active --quiet nfs-kernel-server.service && systemctl stop nfs-kernel-server.service &>/dev/null
        systemctl is-active --quiet rpcbind.service && systemctl stop rpcbind.service &>/dev/null
        systemctl is-active --quiet rpcbind.socket && systemctl stop rpcbind.socket &>/dev/null
        
        systemctl disable nfs-kernel-server.service &>/dev/null && \
        systemctl disable rpcbind.service &>/dev/null && \
        systemctl disable rpcbind.socket &>/dev/null
        status=$?
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac

if [[ $status -eq 0 ]]; then
    echo "true"
else
    echo "false"
fi