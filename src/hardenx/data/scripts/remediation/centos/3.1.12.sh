#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if [[ "$1" != "disabled" ]]; then
    echo "false"
    exit 1
fi

if systemctl --now disable rpcbind &> /dev/null; then
    echo "true"
else
    echo "false"
fi