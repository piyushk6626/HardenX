#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "false"
   exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

CONFIG_FILE="/etc/default/apport"
ACTION="$1"

case "$ACTION" in
    0|1)
        if [[ ! -f "$CONFIG_FILE" ]]; then
            echo "false"
            exit 1
        fi
        
        sed -i "s/^enabled=.*/enabled=$ACTION/" "$CONFIG_FILE"
        
        if grep -q "^enabled=$ACTION$" "$CONFIG_FILE"; then
            echo "true"
            exit 0
        else
            echo "false"
            exit 1
        fi
        ;;
    "Not Installed")
        if ! command -v dpkg &> /dev/null || ! command -v apt-get &> /dev/null; then
            echo "false"
            exit 1
        fi

        if dpkg -s apport &> /dev/null; then
            apt-get purge --auto-remove -y apport &> /dev/null
            if ! dpkg -s apport &> /dev/null; then
                echo "true"
                exit 0
            else
                echo "false"
                exit 1
            fi
        else
            echo "true"
            exit 0
        fi
        ;;
    *)
        echo "false"
        exit 1
        ;;
esac