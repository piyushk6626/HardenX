#!/usr/bin/env bash

if [[ "$1" != "Not Installed" ]]; then
    echo "false"
    exit 0
fi

PKG_MANAGER=""
if command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
else
    echo "false"
    exit 0
fi

if ! rpm -q ftp &>/dev/null; then
    echo "true"
    exit 0
fi

if sudo "$PKG_MANAGER" remove -y ftp &>/dev/null; then
    echo "true"
else
    echo "false"
fi
