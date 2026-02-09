#!/bin/bash

# A more robust check for installation is to see if systemd knows about the units.
# We redirect stderr to /dev/null in case the units don't exist at all.
if ! systemctl cat rpcbind.service &>/dev/null && ! systemctl cat rpcbind.socket &>/dev/null; then
    echo "Not Installed"
    exit 0
fi

if systemctl is-enabled --quiet rpcbind.service 2>/dev/null || systemctl is-enabled --quiet rpcbind.socket 2>/dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi