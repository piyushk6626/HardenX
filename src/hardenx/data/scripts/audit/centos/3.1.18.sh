#!/bin/bash

if command -v rpm &>/dev/null; then
    if rpm -q httpd &>/dev/null || rpm -q nginx &>/dev/null; then
        echo "Installed"
        exit 0
    fi
fi

if command -v dpkg &>/dev/null; then
    if dpkg -s apache2 &>/dev/null || dpkg -s nginx &>/dev/null; then
        echo "Installed"
        exit 0
    fi
fi

echo "Not Installed"