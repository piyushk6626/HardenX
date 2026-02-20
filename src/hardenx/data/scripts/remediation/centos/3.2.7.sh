#!/bin/bash

if [[ "$#" -ne 1 ]] || [[ "$1" != "Install and Enable" ]]; then
    echo "false"
    exit 1
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

# Install chrony if not already installed
if ! rpm -q chrony &>/dev/null; then
    if ! "$PKG_MANAGER" -y install chrony &>/dev/null; then
        echo "false"
        exit 1
    fi
fi

# Enable and start the chronyd service
if ! systemctl enable --now chronyd &>/dev/null; then
    echo "false"
    exit 1
fi

echo "true"
exit 0