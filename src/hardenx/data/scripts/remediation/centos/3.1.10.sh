#!/bin/bash

if [[ "$1" == "Not Installed" ]]; then
    if yum remove -y ypserv &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
fi