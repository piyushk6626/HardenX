#!/bin/bash

if [ "$1" == "not installed" ]; then
    if apt-get purge telnet -y &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi