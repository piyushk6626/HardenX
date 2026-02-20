#!/bin/bash

if [ "$#" -ne 1 ] || [ "$1" != "Not Installed" ]; then
    echo "false"
    exit 1
fi

if command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
else
    echo "false"
    exit 1
fi

# Flag to track overall success
all_successful=true

# Step 1: Remove the package
$PKG_MANAGER remove -y xorg-x11-server-common &>/dev/null
if [ $? -ne 0 ]; then
    all_successful=false
fi

# Step 2: Set the default systemd target
systemctl set-default multi-user.target &>/dev/null
if [ $? -ne 0 ]; then
    all_successful=false
fi

if [ "$all_successful" = true ]; then
    echo "true"
else
    echo "false"
fi