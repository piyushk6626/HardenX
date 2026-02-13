#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

case "$1" in
    Enabled)
        if pam-auth-update --enable pwhistory; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    Disabled)
        if pam-auth-update --disable pwhistory --force; then
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