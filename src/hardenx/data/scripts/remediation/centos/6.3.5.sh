#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

case "$1" in
    Enabled)
        if authconfig --enablefaillock --update &>/dev/null; then
            echo "true"
            exit 0
        else
            echo "false"
            exit 1
        fi
        ;;
    Disabled)
        if authconfig --disablefaillock --update &>/dev/null; then
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