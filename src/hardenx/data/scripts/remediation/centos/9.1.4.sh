#!/bin/bash

if chmod "$1" /etc/group- &>/dev/null; then
    echo "true"
else
    echo "false"
fi