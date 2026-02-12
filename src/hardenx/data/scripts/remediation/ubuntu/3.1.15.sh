#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "false"
    exit 1
fi

ACTION="$1"

case "$ACTION" in
    disabled)
        if systemctl stop snmpd &>/dev/null && systemctl disable snmpd &>/dev/null; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    uninstalled)
        if apt-get purge -y snmp snmpd &>/dev/null; then
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
