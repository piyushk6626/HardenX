#!/usr/bin/env bash

if findmnt -n -o OPTIONS --target /home | grep -q '\bnosuid\b'; then
    echo "true"
else
    echo "false"
fi