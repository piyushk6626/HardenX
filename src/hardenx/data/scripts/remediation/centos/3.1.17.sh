#!/usr/bin/env bash

if [[ "$1" != "Not Installed" ]]; then
    echo "false"
    exit 1
fi

# Detect package manager
if command -v dpkg &> /dev/null; then
    # Debian, Ubuntu, etc.
    if ! dpkg -s squid &> /dev/null; then
        echo "true"
        exit 0
    fi
    if sudo apt-get remove -y squid &> /dev/null; then
        echo "true"
    else
        echo "false"
    fi
elif command -v rpm &> /dev/null; then
    # RHEL, CentOS, Fedora, etc.
    if ! rpm -q squid &> /dev/null; then
        echo "true"
        exit 0
    fi
    if command -v dnf &> /dev/null; then
        if sudo dnf remove -y squid &> /dev/null; then
            echo "true"
        else
            echo "false"
        fi
    elif command -v yum &> /dev/null; then
        if sudo yum remove -y squid &> /dev/null; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "false"
    fi
elif command -v pacman &> /dev/null; then
    # Arch Linux
    if ! pacman -Q squid &> /dev/null; then
        echo "true"
        exit 0
    fi
    if sudo pacman -Rns --noconfirm squid &> /dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
    exit 1
fi