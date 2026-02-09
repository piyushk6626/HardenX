#!/bin/bash

if ! dpkg -s tftpd-hpa &>/dev/null; then
    echo "Not Installed"
    exit 0
fi

if systemctl is-active --quiet tftpd-hpa; then
    echo "Installed and Active"
else
    echo "Installed but Inactive"
fi