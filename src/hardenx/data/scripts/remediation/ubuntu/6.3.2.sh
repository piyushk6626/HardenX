#!/bin/bash

if [[ "$1" == "Installed" ]]; then
    if apt-get update && apt-get install -y libpam-modules; then
        echo "true"
    else
        echo "false"
    fi
fi