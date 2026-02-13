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
    allow|deny)
        if ufw "$ACTION" in on lo &>/dev/null && ufw "$ACTION" out on lo &>/dev/null; then
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