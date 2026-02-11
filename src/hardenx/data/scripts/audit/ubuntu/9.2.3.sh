#!/bin/bash

if [ -z "$(comm -23 <(cut -d: -f4 /etc/passwd | sort -u) <(cut -d: -f3 /etc/group | sort -u))" ]; then
    echo "true"
else
    echo "false"
fi