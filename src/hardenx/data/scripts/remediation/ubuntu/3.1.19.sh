#!/usr/bin/env bash

if [[ $# -ne 1 || "$1" != "Not Installed" ]]; then
    echo "false"
    exit 1
fi

PACKAGE="xinetd"

# Debian/Ubuntu
if command -v apt-get &>/dev/null; then
    # apt-get purge returns 0 even if the package is not installed
    if sudo apt-get purge --auto-remove -y "$PACKAGE" &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
# Fedora/RHEL/CentOS (modern)
elif command -v dnf &>/dev/null; then
    # dnf remove returns 0 even if the package is not installed
    if sudo dnf remove -y "$PACKAGE" &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
# RHEL/CentOS (older)
elif command -v yum &>/dev/null; then
    # yum remove returns 0 even if the package is not installed
    if sudo yum remove -y "$PACKAGE" &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
# Arch Linux
elif command -v pacman &>/dev/null; then
    # pacman -Q returns non-zero if package is not installed
    if ! pacman -Q "$PACKAGE" &>/dev/null; then
        echo "true"
    else
        # If it is installed, attempt removal
        if sudo pacman -Rns --noconfirm "$PACKAGE" &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
    fi
else
    # Unsupported package manager
    echo "false"
fi