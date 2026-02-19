#!/bin/bash

if ! rpm -q nfs-utils &>/dev/null; then
    echo "Not Installed"
    exit 0
fi

if systemctl is-enabled nfs-server &>/dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi