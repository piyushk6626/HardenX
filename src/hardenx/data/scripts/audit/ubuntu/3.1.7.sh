#!/bin/bash

if command -v dpkg &>/dev/null; then
    if dpkg -s slapd &>/dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
elif command -v rpm &>/dev/null; then
    if rpm -q slapd &>/dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
elif command -v pacman &>/dev/null; then
    if pacman -Q slapd &>/dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
else
    echo "Not Installed"
fi