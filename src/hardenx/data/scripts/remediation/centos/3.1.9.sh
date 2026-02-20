#!/usr/bin/env bash

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    "Disabled")
        if systemctl --now disable nfs-server rpcbind &>/dev/null; then
            echo "true"
            exit 0
        else
            echo "false"
            exit 1
        fi
        ;;

    "Not Installed")
        PKG_MANAGER=""
        if command -v dnf &>/dev/null; then
            PKG_MANAGER="dnf"
        elif command -v yum &>/dev/null; then
            PKG_MANAGER="yum"
        else
            echo "false"
            exit 1
        fi

        if "${PKG_MANAGER}" remove -y nfs-utils &>/dev/null; then
            echo "true"
            exit 0
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