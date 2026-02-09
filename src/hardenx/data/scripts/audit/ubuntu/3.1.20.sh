#!/usr/bin/env bash

if dpkg -s xserver-xorg &> /dev/null; then
    echo "Installed"
else
    echo "Not Installed"
fi