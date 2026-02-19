#!/usr/bin/env bash

if [ -f /boot/grub2/grub.cfg ]; then
    if grep -qE '^\s*(linux|linux16|linuxefi)\s+.*\baudit=1\b' /boot/grub2/grub.cfg; then
        echo "Enabled"
    else
        echo "Disabled"
    fi
else
    echo "Disabled"
fi