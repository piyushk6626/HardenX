#!/bin/bash

if findmnt -n -o OPTIONS /var | grep -q '\bnosuid\b'; then
    echo "enabled"
else
    echo "disabled"
fi