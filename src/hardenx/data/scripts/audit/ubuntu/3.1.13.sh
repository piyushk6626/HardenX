#!/bin/bash

if ! command -v rsync &>/dev/null; then
    echo "Not Installed"
else
    systemctl is-enabled rsync
fi