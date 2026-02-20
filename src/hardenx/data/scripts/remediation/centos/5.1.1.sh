#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"

case "$DESIRED_STATE" in
    "Installed")
        PKG_MANAGER=""
        if command -v dnf &>/dev/null; then
            PKG_MANAGER="dnf"
        elif command -v yum &>/dev/null; then
            PKG_MANAGER="yum"
        else
            echo "false"
            exit 1
        fi

        if rpm -q ufw &>/dev/null; then
            echo "true"
            exit 0
        fi

        if sudo "${PKG_MANAGER}" install -y ufw &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;

    "Not Installed")
        echo "true"
        ;;

    *)
        echo "false"
        exit 1
        ;;
esac