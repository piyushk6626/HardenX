#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    Enabled)
        if authconfig --enablefaillock --faillockargs="deny=5 unlock_time=900" --updateall &>/dev/null; then
            echo "true"
            exit 0
        else
            echo "false"
            exit 1
        fi
        ;;
    Disabled)
        if authconfig --disablefaillock --updateall &>/dev/null; then
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