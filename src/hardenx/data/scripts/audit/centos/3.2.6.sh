#!/bin/bash

PACKAGE_TO_CHECK="ftp"

if command -v dpkg &> /dev/null; then
    # Debian/Ubuntu based systems
    if dpkg -s "$PACKAGE_TO_CHECK" &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
elif command -v rpm &> /dev/null; then
    # Red Hat/CentOS/Fedora based systems
    if rpm -q "$PACKAGE_TO_CHECK" &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
elif command -v pacman &> /dev/null; then
    # Arch based systems
    if pacman -Q "$PACKAGE_TO_CHECK" &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
else
    # Fallback for unknown package managers
    echo "Not Installed"
fi