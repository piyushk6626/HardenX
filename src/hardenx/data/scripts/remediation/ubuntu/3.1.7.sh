#!/bin/bash

if [[ "$1" == "Not Installed" ]]; then
    if sudo apt-get purge -y slapd &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
fi