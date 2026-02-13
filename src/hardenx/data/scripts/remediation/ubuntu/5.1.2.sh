#!/bin/bash

if [[ "$1" == "ufw" ]]; then
    if apt-get purge -y iptables-persistent &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
elif [[ "$1" == "iptables-persistent" ]]; then
    if apt-get purge -y ufw &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi