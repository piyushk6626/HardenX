#!/usr/bin/env bash

if [[ "${EUID}" -ne 0 ]]; then
    echo "false"
    exit 1
fi

if [[ "$#" -ne 1 ]] || [[ "$1" != "disabled" ]]; then
    echo "false"
    exit 1
fi

if ! echo "install cramfs /bin/true" > /etc/modprobe.d/cramfs.conf; then
    echo "false"
    exit 1
fi

if lsmod | grep -q "^cramfs "; then
    if ! modprobe -r cramfs; then
        echo "false"
        exit 1
    fi
fi

echo "true"
exit 0