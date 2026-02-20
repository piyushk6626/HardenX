#!/bin/bash

if [ "$1" == "Installed" ]; then
    if yum install -y sudo &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi