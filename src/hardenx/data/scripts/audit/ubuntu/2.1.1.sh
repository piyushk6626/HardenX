#!/bin/bash

if grep -q "password_pbkdf2" /boot/grub/grub.cfg 2>/dev/null; then
    echo "Enabled"
else
    echo "Disabled"
fi