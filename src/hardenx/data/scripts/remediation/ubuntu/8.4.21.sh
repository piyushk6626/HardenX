#!/bin/bash

if [[ "$1" == "same" ]]; then
    if augenrules --load &>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
else
    echo "false"
fi