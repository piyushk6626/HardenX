#!/bin/bash

if findmnt --noheadings --output OPTIONS /tmp | grep -q '\bnodev\b'; then
    echo "enabled"
else
    echo "disabled"
fi