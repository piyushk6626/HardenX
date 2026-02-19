#!/bin/bash

if findmnt -n -o OPTIONS /home | grep -q '\bnosuid\b'; then
    echo "Present"
else
    echo "Absent"
fi