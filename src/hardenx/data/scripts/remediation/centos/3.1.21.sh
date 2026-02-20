#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

if postconf -e "inet_interfaces=$1" &>/dev/null && systemctl restart postfix &>/dev/null; then
    echo "true"
else
    echo "false"
fi