#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "false"
    exit 1
fi

DESIRED_STATE="$1"

case "$DESIRED_STATE" in
    "Not Installed")
        if command -v apt-get &> /dev/null; then
            CMD="apt-get purge -y autofs"
        elif command -v dnf &> /dev/null; then
            CMD="dnf remove -y autofs"
        elif command -v yum &> /dev/null; then
            CMD="yum remove -y autofs"
        else
            echo "false"
            exit 1
        fi

        if $CMD &> /dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;

    "Disabled")
        if ! command -v systemctl &> /dev/null; then
             echo "false"
             exit 1
        fi

        if systemctl stop autofs &> /dev/null && systemctl disable autofs &> /dev/null; then
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