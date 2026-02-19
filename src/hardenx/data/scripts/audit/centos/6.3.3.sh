#!/bin/bash

if command -v dpkg &> /dev/null; then
    if dpkg-query -W -f='${Status}' libpam-pwquality 2>/dev/null | grep -q "install ok installed"; then
        echo "installed"
    else
        echo "not installed"
    fi
elif command -v rpm &> /dev/null; then
    if rpm -q libpam-pwquality &> /dev/null; then
        echo "installed"
    else
        echo "not installed"
    fi
else
    echo "not installed"
fi