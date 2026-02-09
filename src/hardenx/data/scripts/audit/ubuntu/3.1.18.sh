#!/usr/bin/env bash

if command -v dpkg &>/dev/null; then
    if dpkg-query -W -f='${Status}\n' apache2 nginx lighttpd 2>/dev/null | grep -q "install ok installed"; then
        echo "Installed"
        exit 0
    fi
fi

if command -v rpm &>/dev/null; then
    if rpm -q apache2 &>/dev/null || rpm -q nginx &>/dev/null || rpm -q lighttpd &>/dev/null; then
        echo "Installed"
        exit 0
    fi
fi

echo "Not Installed"