#!/bin/bash

DESIRED_STATE="Not Installed"

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

if [ "$1" != "${DESIRED_STATE}" ]; then
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

# yum and dnf exit 0 if the package is already absent, which counts as success.
if ${PKG_MANAGER} remove -y rsyslog &>/dev/null; then
    echo "true"
    exit 0
else
    echo "false"
    exit 1
fi