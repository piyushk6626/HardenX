#!/usr/bin/env bash

if [[ "$1" != "Installed" ]]; then
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
    exit 1
fi

if ${PKG_MANAGER} install -y pam &>/dev/null; then
    echo "true"
else
    echo "false"
fi