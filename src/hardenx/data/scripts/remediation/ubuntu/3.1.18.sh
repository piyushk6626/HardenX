#!/bin/bash

if [[ "$1" == "Not Installed" ]]; then
    if apt-get purge -y apache2 nginx lighttpd &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "true"
fi