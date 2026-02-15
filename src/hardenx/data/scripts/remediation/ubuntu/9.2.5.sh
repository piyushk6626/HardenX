#!/bin/bash

duplicate_count=$(cut -d: -f3 /etc/passwd | sort | uniq -d | wc -l)

if [ "${duplicate_count}" -eq 0 ]; then
    echo "true"
else
    echo "false"
fi