#!/bin/bash

if command -v dpkg &> /dev/null; then
    if dpkg -s ufw &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
elif command -v rpm &> /dev/null; then
    if rpm -q ufw &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
elif command -v pacman &> /dev/null; then
    if pacman -Q ufw &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
else
    # Fallback if no known package manager is found
    if command -v ufw &> /dev/null; then
        echo "Installed"
    else
        echo "Not Installed"
    fi
fi