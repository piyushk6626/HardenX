#!/bin/bash

if findmnt --noheadings --output OPTIONS --target /tmp | grep -wq 'noexec'; then
    echo "enabled"
else
    echo "disabled"
fi