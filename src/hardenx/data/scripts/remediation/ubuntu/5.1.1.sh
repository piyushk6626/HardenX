#!/usr/bin/env bash

if [[ "$1" != "Installed" ]]; then
    echo "false"
    exit 1
fi

PACKAGE_NAME="ufw"

# Detect package manager and attempt installation
# Redirect stdout/stderr to /dev/null to suppress installer messages
if command -v apt-get &>/dev/null; then
    if sudo apt-get update -y >/dev/null 2>&1 && sudo apt-get install -y "$PACKAGE_NAME" >/dev/null 2>&1; then
        echo "true"
        exit 0
    else
        echo "false"
        exit 1
    fi
elif command -v dnf &>/dev/null; then
    if sudo dnf install -y "$PACKAGE_NAME" >/dev/null 2>&1; then
        echo "true"
        exit 0
    else
        echo "false"
        exit 1
    fi
elif command -v yum &>/dev/null; then
    if sudo yum install -y "$PACKAGE_NAME" >/dev/null 2>&1; then
        echo "true"
        exit 0
    else
        echo "false"
        exit 1
    fi
elif command -v pacman &>/dev/null; then
    if sudo pacman -Syu --noconfirm "$PACKAGE_NAME" >/dev/null 2>&1; then
        echo "true"
        exit 0
    else
        echo "false"
        exit 1
    fi
else
    # No supported package manager found
    echo "false"
    exit 1
fi