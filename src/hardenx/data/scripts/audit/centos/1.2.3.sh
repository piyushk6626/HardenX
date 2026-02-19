#!/bin/bash

if findmnt -n -o OPTIONS /tmp | grep -q '\bnosuid\b'; then
    echo "Enabled"
else
    echo "Disabled"
fi