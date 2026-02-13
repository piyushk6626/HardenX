#!/bin/bash

if [[ "$1" != "Install" ]]; then
    echo "false"
    exit 1
fi

if dpkg -s auditd &> /dev/null && dpkg -s audispd-plugins &> /dev/null; then
    echo "true"
    exit 0
fi

if apt-get install -y auditd audispd-plugins &> /dev/null; then
    echo "true"
else
    echo "false"
fi