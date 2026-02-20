#!/usr/bin/env bash

if [[ "$1" != "Not Installed" ]]; then
    exit 0
fi

PKG_MANAGER_CMD=""

if command -v apt-get &>/dev/null; then
    PKG_MANAGER_CMD="sudo apt-get remove -y tftp-server"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER_CMD="sudo dnf remove -y tftp-server"
elif command -v yum &>/dev/null; then
    PKG_MANAGER_CMD="sudo yum remove -y tftp-server"
fi

if [[ -n "$PKG_MANAGER_CMD" ]]; then
    if $PKG_MANAGER_CMD &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi