#!/bin/bash

if [[ "$1" != "Installed" ]]; then
    echo "false"
    exit 1
fi

if ! command -v apt-get &> /dev/null; then
    echo "false"
    exit 1
fi

if apt-get install -y aide &> /dev/null && aideinit &> /dev/null; then
    echo "true"
else
    echo "false"
fi