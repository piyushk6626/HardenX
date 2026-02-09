#!/usr/bin/env bash

packages_dpkg=("vsftpd" "proftpd-basic" "pure-ftpd")
packages_rpm=("vsftpd" "proftpd" "pure-ftpd")
found=0

if command -v dpkg &> /dev/null; then
    for pkg in "${packages_dpkg[@]}"; do
        if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
            found=1
            break
        fi
    done
elif command -v rpm &> /dev/null; then
    for pkg in "${packages_rpm[@]}"; do
        if rpm -q "$pkg" &> /dev/null; then
            found=1
            break
        fi
    done
fi

if [ "$found" -eq 1 ]; then
    echo "Installed"
else
    echo "Not Installed"
fi