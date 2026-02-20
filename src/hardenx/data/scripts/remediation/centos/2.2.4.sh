#!/bin/bash

if [[ "$1" != "not installed" ]]; then
    exit 1
fi

PACKAGE_NAME="prelink"
SUDO=""
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

# Debian/Ubuntu
if command -v dpkg &>/dev/null && command -v apt-get &>/dev/null; then
    if ! dpkg -s "$PACKAGE_NAME" &>/dev/null; then
        echo "true"
        exit 0
    fi
    if $SUDO apt-get remove --purge -y "$PACKAGE_NAME" &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
    exit $?
fi

# RHEL/CentOS/Fedora/SUSE
if command -v rpm &>/dev/null; then
    if ! rpm -q "$PACKAGE_NAME" &>/dev/null; then
        echo "true"
        exit 0
    fi
    
    PM=""
    if command -v dnf &>/dev/null; then
        PM="dnf"
    elif command -v yum &>/dev/null; then
        PM="yum"
    elif command -v zypper &>/dev/null; then
        PM="zypper"
    fi

    if [[ -n "$PM" ]]; then
        if $SUDO "$PM" remove -y "$PACKAGE_NAME" &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        exit $?
    fi
fi

# Arch Linux
if command -v pacman &>/dev/null; then
    if ! pacman -Q "$PACKAGE_NAME" &>/dev/null; then
        echo "true"
        exit 0
    fi
    if $SUDO pacman -Rns --noconfirm "$PACKAGE_NAME" &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
    exit $?
fi

# If no known package manager found, we cannot determine state.
echo "false"
exit 1