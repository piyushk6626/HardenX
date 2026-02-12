#!/bin/bash

if [[ "$1" != "Enabled" ]]; then
    exit 1
fi

install_chrony() {
    if command -v apt-get &> /dev/null; then
        dpkg -s chrony &> /dev/null || { apt-get update -y &>/dev/null && apt-get install -y chrony &>/dev/null; }
    elif command -v dnf &> /dev/null; then
        dnf -q list installed chrony &> /dev/null || dnf install -y chrony &> /dev/null
    elif command -v yum &> /dev/null; then
        yum -q list installed chrony &> /dev/null || yum install -y chrony &> /dev/null
    else
        return 1
    fi
    return $?
}

install_chrony && systemctl enable --now chrony &> /dev/null
exit $?