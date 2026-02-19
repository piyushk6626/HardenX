#!/bin/bash

if ! rpm -q vsftpd &>/dev/null; then
    echo "Not Installed"
else
    systemctl is-enabled vsftpd
fi