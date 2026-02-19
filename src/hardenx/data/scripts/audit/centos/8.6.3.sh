#!/usr/bin/env bash

if command -v dpkg &> /dev/null; then
    if dpkg -s aide &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
elif command -v rpm &> /dev/null; then
    if rpm -q aide &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
elif command -v pacman &> /dev/null; then
    if pacman -Q aide &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
else
    echo "Not Installed"
fi