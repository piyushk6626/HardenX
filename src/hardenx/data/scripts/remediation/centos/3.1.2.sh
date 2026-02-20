#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

STATE="$1"

case "$STATE" in
    disabled)
        if systemctl stop avahi-daemon.service &>/dev/null && systemctl disable avahi-daemon.service &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    'not installed')
        REMOVE_CMD=""
        # Debian/Ubuntu
        if command -v apt-get &>/dev/null; then
            REMOVE_CMD="apt-get remove --purge -y avahi-daemon"
        # Fedora/RHEL 8+
        elif command -v dnf &>/dev/null; then
            REMOVE_CMD="dnf remove -y avahi"
        # RHEL 7/CentOS 7
        elif command -v yum &>/dev/null; then
            REMOVE_CMD="yum remove -y avahi"
        # Arch Linux
        elif command -v pacman &>/dev/null; then
            REMOVE_CMD="pacman -Rns --noconfirm avahi"
        # SUSE
        elif command -v zypper &>/dev/null; then
            REMOVE_CMD="zypper remove -y avahi"
        else
            echo "false"
            exit 1
        fi

        if $REMOVE_CMD &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac