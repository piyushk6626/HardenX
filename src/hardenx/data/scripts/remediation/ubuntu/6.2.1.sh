#!/usr/bin/env bash

if [[ "$1" == "Installed" ]]; then
    if apt-get update &>/dev/null && apt-get install -y sudo &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi