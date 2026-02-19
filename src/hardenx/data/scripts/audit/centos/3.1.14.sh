#!/bin/bash

if rpm -q samba &>/dev/null; then
    systemctl is-enabled smb
else
    echo "Not Installed"
fi