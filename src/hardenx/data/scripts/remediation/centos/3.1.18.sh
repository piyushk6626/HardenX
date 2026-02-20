#!/usr/bin/env bash

if [[ "$1" != "Not Installed" ]]; then
    exit 0
fi

PKG_MANAGER=""
if command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
else
    echo "false"
    exit 1
fi

if sudo "${PKG_MANAGER}" remove -y httpd nginx &>/dev/null; then
    echo "true"
else
    echo "false"
fi