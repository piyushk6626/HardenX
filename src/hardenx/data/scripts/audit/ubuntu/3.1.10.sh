#!/bin/bash

if command -v dpkg &>/dev/null; then
    if dpkg-query -W -f='${Status}' nis 2>/dev/null | grep -q "install ok installed"; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
elif command -v rpm &>/dev/null; then
    if rpm -q nis &>/dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
else
    echo "Not Installed"
fi