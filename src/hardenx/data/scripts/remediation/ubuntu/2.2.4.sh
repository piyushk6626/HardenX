#!/usr/bin/env bash

if [ "$1" = "Not Installed" ]; then
    if dpkg -s prelink &> /dev/null; then
        if apt-get purge -y prelink &> /dev/null; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "true"
    fi
fi