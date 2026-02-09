#!/bin/bash

if (command -v dpkg &>/dev/null && dpkg-query -W -f='${Status}' nis 2>/dev/null | grep -q "install ok installed") || \
   (command -v rpm &>/dev/null && rpm -q nis &>/dev/null); then
    echo "Installed"
else
    echo "Not Installed"
fi