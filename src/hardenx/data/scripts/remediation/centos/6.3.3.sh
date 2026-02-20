#!/bin/bash

if [[ $# -ne 1 || ("$1" != "installed" && "$1" != "uninstalled") ]]; then
    echo "false"
    exit 1
fi

PACKAGE="libpam-pwquality"
DESIRED_STATE="$1"

if command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
elif command -v yum &>/dev/null; then
    PKG_MGR="yum"
else
    echo "false"
    exit 1
fi

is_installed() {
    rpm -q "$PACKAGE" &>/dev/null
}

if [[ "$DESIRED_STATE" == "installed" ]]; then
    if is_installed; then
        echo "true"
        exit 0
    fi
    if sudo "$PKG_MGR" install -y "$PACKAGE" &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
elif [[ "$DESIRED_STATE" == "uninstalled" ]]; then
    if ! is_installed; then
        echo "true"
        exit 0
    fi
    if sudo "$PKG_MGR" remove -y "$PACKAGE" &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
fi