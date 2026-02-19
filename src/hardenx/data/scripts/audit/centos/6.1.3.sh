#!/bin/bash

for key_file in /etc/ssh/*.pub; do
    if [ -f "$key_file" ]; then
        stat -c "%a" "$key_file"
    fi
done