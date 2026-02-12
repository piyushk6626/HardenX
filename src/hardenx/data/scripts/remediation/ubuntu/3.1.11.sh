#!/bin/bash

if [[ "$1" == "disabled" ]] && systemctl --now disable cups.service &>/dev/null; then
    echo "true"
else
    echo "false"
fi