#!/bin/bash

if [[ "$1" == "same" ]]; then
    if augenrules --load; then
        echo "true"
    else
        echo "false"
    fi
fi