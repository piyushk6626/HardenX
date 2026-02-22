#!/usr/bin/env bash

if [[ "$(id -u)" -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

if ! command -v grubby &> /dev/null; then
    echo "false"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    Enabled)
        if grubby --update-kernel=ALL --args="audit=1" &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    Disabled)
        if grubby --update-kernel=ALL --remove-args="audit=1" &>/dev/null; then
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