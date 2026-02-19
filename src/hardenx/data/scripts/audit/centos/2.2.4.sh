#!/usr/bin/env bash

if ( command -v dpkg &>/dev/null && dpkg-query -W -f='${Status}' prelink 2>/dev/null | grep -q "install ok installed" ) || \
   ( command -v rpm &>/dev/null && rpm -q prelink &>/dev/null ) || \
   ( command -v pacman &>/dev/null && pacman -Q prelink &>/dev/null ) || \
   ( command -v apk &>/dev/null && apk -e info prelink &>/dev/null ); then
    echo "installed"
else
    echo "not installed"
fi