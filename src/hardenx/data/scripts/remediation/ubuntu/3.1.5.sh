#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    disabled)
        if systemctl stop dnsmasq &>/dev/null && systemctl disable dnsmasq &>/dev/null; then
            echo "true"
            exit 0
        else
            echo "false"
            exit 1
        fi
        ;;
    not-installed)
        if command -v apt-get &> /dev/null; then
            if apt-get purge --auto-remove -y dnsmasq &>/dev/null; then
                echo "true"
                exit 0
            else
                echo "false"
                exit 1
            fi
        elif command -v dnf &> /dev/null; then
            if dnf remove -y dnsmasq &>/dev/null; then
                echo "true"
                exit 0
            else
                echo "false"
                exit 1
            fi
        elif command -v yum &> /dev/null; then
            if yum remove -y dnsmasq &>/dev/null; then
                echo "true"
                exit 0
            else
                echo "false"
                exit 1
            fi
        else
            echo "false"
            exit 1
        fi
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac