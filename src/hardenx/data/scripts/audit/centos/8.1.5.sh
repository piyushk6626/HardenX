#!/usr/bin/env bash

if (command -v dpkg &>/dev/null && dpkg -s rsyslog &>/dev/null) || \
   (command -v rpm &>/dev/null && rpm -q rsyslog &>/dev/null) || \
   (command -v pacman &>/dev/null && pacman -Q rsyslog &>/dev/null) || \
   (command -v apk &>/dev/null && apk -e info rsyslog &>/dev/null); then
    echo "Installed"
else
    echo "Not Installed"
fi