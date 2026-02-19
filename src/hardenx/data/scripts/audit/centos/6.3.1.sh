#!/usr/bin/env bash

PKG_NAME="pam"

# Debian/Ubuntu with APT
if command -v apt-get &> /dev/null; then
    if ! dpkg -l "$PKG_NAME" &> /dev/null; then
        echo "Not Installed"
        exit 0
    fi

    policy=$(apt-cache policy "$PKG_NAME")
    installed=$(echo "$policy" | grep -oP '^\s{2}Installed: \K[^\s]+')
    candidate=$(echo "$policy" | grep -oP '^\s{2}Candidate: \K[^\s]+')

    if [[ "$installed" == "(none)" ]]; then
        echo "Not Installed"
    elif [[ "$installed" == "$candidate" ]]; then
        echo "Installed and Up-to-date"
    else
        echo "Update Available"
    fi
    exit 0
fi

# RHEL/CentOS/Fedora with DNF/YUM
if command -v dnf &> /dev/null || command -v yum &> /dev/null; then
    PM=$(command -v dnf || command -v yum)
    
    if ! rpm -q "$PKG_NAME" &> /dev/null; then
        echo "Not Installed"
        exit 0
    fi

    $PM check-update "$PKG_NAME" -q &> /dev/null
    exit_code=$?

    if [[ $exit_code -eq 100 ]]; then
        echo "Update Available"
    elif [[ $exit_code -eq 0 ]]; then
        echo "Installed and Up-to-date"
    else
        # For other errors, assume up-to-date based on installation check
        echo "Installed and Up-to-date"
    fi
    exit 0
fi

# Arch Linux with Pacman
if command -v pacman &> /dev/null; then
    if ! pacman -Q "$PKG_NAME" &> /dev/null; then
        echo "Not Installed"
        exit 0
    fi

    # Assumes `pacman -Sy` has been run recently by the user
    if pacman -Qu --quiet | grep -q "^$PKG_NAME "; then
        echo "Update Available"
    else
        echo "Installed and Up-to-date"
    fi
    exit 0
fi

# Fallback if no known package manager is found
echo "Unsupported package manager" >&2
exit 1