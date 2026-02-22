#!/bin/bash

if [[ "$1" != "Install" ]]; then
    echo "false"
    exit 0
fi

if yum install -y aide &>/dev/null; then
    echo "true"
else
    echo "false"
fi