#!/bin/bash

config_file="/boot/grub2/grub.cfg"

if [ ! -f "$config_file" ]; then
    echo 'Disabled'
    exit 0
fi

if grep -q '^set superusers' "$config_file" && grep -q '^password_pbkdf2' "$config_file"; then
    echo 'Enabled'
else
    echo 'Disabled'
fi