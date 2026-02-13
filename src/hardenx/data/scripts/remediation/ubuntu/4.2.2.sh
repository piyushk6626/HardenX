#!/bin/bash

if [[ "$1" != "Disabled" ]]; then
    echo "false"
    exit 1
fi

if lsmod | grep -q "^tipc\s"; then
    if ! rmmod tipc; then
        echo "false"
        exit 1
    fi
fi

if ! echo "install tipc /bin/true" > /etc/modprobe.d/disable-tipc.conf; then
    echo "false"
    exit 1
fi

echo "true"
exit 0