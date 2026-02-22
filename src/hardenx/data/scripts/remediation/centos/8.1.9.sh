#!/usr/bin/env bash

if [[ "$1" != "enabled" ]]; then
    echo "false"
    exit 1
fi

# Determine the package manager
PKG_MANAGER=""
if command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
else
    echo "false"
    exit 1
fi

# Install rsyslog if it's not already installed
if ! rpm -q rsyslog &>/dev/null; then
    if ! "$PKG_MANAGER" install -y rsyslog &>/dev/null; then
        echo "false"
        exit 1
    fi
fi

# Enable and start the rsyslog service
if ! systemctl enable --now rsyslog &>/dev/null; then
    echo "false"
    exit 1
fi

echo "true"