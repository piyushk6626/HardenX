#!/usr/bin/env bash

if [[ "$1" != "Installed" ]]; then
    exit 0
fi

PACKAGE_NAME="logrotate"

if command -v dnf &>/dev/null; then
    dnf install -y "$PACKAGE_NAME"
elif command -v yum &>/dev/null; then
    yum install -y "$PACKAGE_NAME"
elif command -v apt-get &>/dev/null; then
    apt-get update && apt-get install -y "$PACKAGE_NAME"
elif command -v zypper &>/dev/null; then
    zypper --non-interactive install "$PACKAGE_NAME"
else
    exit 1
fi