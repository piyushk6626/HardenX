#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    "Not Installed")
        if command -v apt-get &> /dev/null; then
            if apt-get purge -y rsync &> /dev/null; then
                echo "true"
            else
                echo "false"
            fi
        elif command -v dnf &> /dev/null; then
            if dnf remove -y rsync &> /dev/null; then
                echo "true"
            else
                echo "false"
            fi
        elif command -v yum &> /dev/null; then
            if yum remove -y rsync &> /dev/null; then
                echo "true"
            else
                echo "false"
            fi
        elif command -v pacman &> /dev/null; then
            if pacman -Rns --noconfirm rsync &> /dev/null; then
                echo "true"
            else
                echo "false"
            fi
        else
            echo "false"
        fi
        ;;
    "Disabled")
        if systemctl disable --now rsyncd &> /dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    *)
        echo "false"
        ;;
esac