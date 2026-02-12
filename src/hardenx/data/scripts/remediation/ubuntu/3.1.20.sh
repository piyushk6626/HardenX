#!/bin/bash

STATE="$1"

if [[ "$STATE" != "Not Installed" ]]; then
    echo "false"
    exit 1
fi

if ! dpkg -l xserver-xorg-core &>/dev/null; then
    echo "true"
    exit 0
fi

if apt-get purge --auto-remove -y xserver-xorg* &>/dev/null; then
    echo "true"
else
    echo "false"
fi