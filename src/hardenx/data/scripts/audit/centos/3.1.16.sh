#!/usr/bin/env bash

if command -v rpm &>/dev/null; then
    if rpm -q tftp-server &>/dev/null; then
        echo "Installed"
        exit 0
    fi
fi

if command -v dpkg &>/dev/null; then
    if dpkg-query -W -f='${Status}' tftp-server 2>/dev/null | grep -q "install ok installed"; then
        echo "Installed"
        exit 0
    fi
fi

echo "Not Installed"